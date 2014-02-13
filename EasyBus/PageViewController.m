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
#import "Favorite+FavoriteWithAdditions.h"
#import "NSManagedObjectContext+Group.h"

@interface PageViewController()

@property(nonatomic) PageViewControllerDatasource* _datasource;

@end

@implementation PageViewController
objection_requires(@"managedObjectContext", @"locationManager", @"pageDataSource")

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
}

- (void)viewWillAppear:(BOOL)animated {
    //Reinit pages
    [self.pageDataSource reset];
    UIViewController *startingViewController = [self.pageDataSource viewControllerAtIndex:0 storyboard:self.storyboard];
    [self setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //Move page view to nearest groupe
    [self gotoNearestPage];

    // Abonnement au notifications des départs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedStarted:) name:departuresUpdateStartedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedSucceeded:) name:departuresUpdateSucceededNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    //Désabonnement aux notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - scrolling
- (void)scrollToPage:(NSInteger)page {
    //Get current page
    int currentPage = ((DeparturesViewController*)[[self viewControllers]objectAtIndex:0]).page;
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
    //Get location
    CLLocation* currentLocation = [self.locationManager currentLocation];

    //Compute nearest group
    NSArray* groupes = [self.managedObjectContext groups];
    double minDistance = MAXFLOAT;
    int index = -1;
    for (int i=0; i<[groupes count]; i++) {
        Group* groupe = [groupes objectAtIndex:i];
        Favorite* firstFavorite = [[groupe favorites] objectAtIndex:0];
        CLLocationDistance currentDistance = [firstFavorite.stop.location distanceFromLocation:currentLocation];
        if (currentDistance < minDistance) {
            index = i;
            minDistance = currentDistance;
        }
    }
    
    //Move page view to nearest groupe
    [self scrollToPage:index];
}

#pragma mark - refreshing location
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
