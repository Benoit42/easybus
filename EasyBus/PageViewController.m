//
//  PageViewController.m
//  EasyBus
//
//  Created by Benoit on 26/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "NSObject+AsyncPerformBlock.h"
#import "Constants.h"
#import "PageViewController.h"
#import "PageViewControllerDatasource.h"
#import "DeparturesManager.h"
#import "Trip+Additions.h"
#import "NSManagedObjectContext+Group.h"
#import "NSManagedObjectContext+Trip.h"
#import "AppDelegate.h"

@interface PageViewController()

@property(nonatomic) PageViewControllerDatasource* _datasource;

@end

@implementation PageViewController
objection_requires(@"managedObjectContext", @"locationManager", @"pageDataSource", @"departuresManager")

#pragma mark - Constructor/destructor
- (void)dealloc {
    //Désabonnement aux notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext);
    NSParameterAssert(self.locationManager);
    NSParameterAssert(self.pageDataSource);

    //Set delegate and datasource
    self.delegate = self;
    self.dataSource = self.pageDataSource;
    UIViewController *startingViewController = [self.pageDataSource viewControllerAtIndex:0 storyboard:self.storyboard];
    [self setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    // Couleur de fond vert Star
    self.view.backgroundColor = Constants.starGreenColor;

    // Abonnement au notifications du contexte (même en arrière plan)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:applicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    //Move page view to nearest groupe
    [self gotoNearestPage];

    // Abonnement au notifications des départs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedStarted:) name:departuresUpdateStartedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedSucceeded:) name:departuresUpdateSucceededNotification object:nil];

    [self performBlockInBackground:^{
        [self.departuresManager refreshDepartures:self.managedObjectContext.trips];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    //Désabonnement aux notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:departuresUpdateStartedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:departuresUpdateSucceededNotification object:nil];
}

#pragma mark - scrolling
- (void)scrollToPage:(NSInteger)page {
    //Get current page
    int currentPage = ((DeparturesNavigationController*)[[self viewControllers]objectAtIndex:0]).page;
    if (page != currentPage) {
        int increment = (page>currentPage)?1:-1;
        int nextPage = currentPage+increment;
        UIPageViewControllerNavigationDirection direction = (increment == 1)?UIPageViewControllerNavigationDirectionForward:UIPageViewControllerNavigationDirectionReverse;
        UIViewController *currentViewController = [self.pageDataSource viewControllerAtIndex:currentPage storyboard:self.storyboard];
        for (int i=nextPage; i!=page+increment; i+=increment) {
            //Move to page
            UIViewController *nextViewController;
            if (increment == 1) {
                nextViewController = [self.pageDataSource pageViewController:self viewControllerAfterViewController:currentViewController];
            }
            else {
                nextViewController = [self.pageDataSource pageViewController:self viewControllerBeforeViewController:currentViewController];
                
            }
            dispatch_sync(dispatch_get_global_queue(
                                                     DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self setViewControllers:@[nextViewController] direction:direction animated:YES completion:nil];
            });
            
            currentViewController = nextViewController;
        }
    }
}

- (void)gotoNearestPage {
    //Get current location
    CLLocation* currentLocation = [self.locationManager currentLocation];

    //Compute nearest group
    NSArray* groupes = [self.managedObjectContext groups];
    NSArray* sortedGroupes = [groupes sortedArrayUsingComparator:^NSComparisonResult(Group* groupe1, Group* groupe2) {
        //Remarque : should always have trips, but prefer toi check anymore
        if (groupe1.trips.count > 0 && groupe2.trips.count > 0) {
            return [[NSNumber numberWithDouble:[((Trip*)groupe1.trips[0]).stop.location distanceFromLocation:currentLocation]] compare:[NSNumber numberWithDouble:[((Trip*)groupe2.trips[0]).stop.location distanceFromLocation:currentLocation]]];
        }
        else if (groupe1.trips.count > 0) {
            return NSOrderedAscending;
        }
        else if (groupe2.trips.count > 0) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    
    //Move page view to nearest groupe
    NSUInteger index = [groupes indexOfObject:sortedGroupes[0]];
    [self scrollToPage:index];
}

#pragma mark - notifications
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    NSLog(@"Application did become active, refreshing");
#warning background pas nécessaire ici ?
    [self performBlockInBackground:^{
        [self.departuresManager refreshDepartures:self.managedObjectContext.trips];
    }];
}

- (void)dataUpdated:(NSNotification *)notification {
    //Raffraichissement des départs
    NSArray* trips = [self.managedObjectContext trips];
    [self.departuresManager refreshDepartures:trips];

    //Reset des pages
    [self.pageDataSource reset];
    UIViewController *startingViewController = [self.pageDataSource viewControllerAtIndex:0 storyboard:self.storyboard];
    [self setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)departuresUpdatedStarted:(NSNotification *)notification {
    [self.locationManager startUpdatingLocation];
}

- (void)departuresUpdatedSucceeded:(NSNotification *)notification {
    [self performBlockOnMainThread:^{
        //Move page view to nearest groupe
        [self gotoNearestPage];
    }];
}

@end
