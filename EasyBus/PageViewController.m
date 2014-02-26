//
//  PageViewController.m
//  EasyBus
//
//  Created by Benoit on 26/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
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

    //Create near stops group if needed
    Group* nearStopGroup = [self.managedObjectContext nearStopGroup];
    if (!nearStopGroup) {
        //Création du groupe des arrêts proches
        nearStopGroup = [self.managedObjectContext addGroupWithName:@"à proximité" isNearStopGroup:YES];
    }
    [nearStopGroup removeTrips:[nearStopGroup trips]];
    
    //Set delegate and datasource
    self.delegate = self;
    self.dataSource = self.pageDataSource;
    UIViewController *startingViewController = [self.pageDataSource viewControllerForGroup:nearStopGroup storyboard:self.storyboard];
    [self setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    // Couleur de fond vert Star
    self.view.backgroundColor = Constants.starGreenColor;

    // Abonnement au notifications du contexte (même en arrière plan)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:applicationDidBecomeActiveNotification object:nil];

    //Abonnement aux notification de géolocalisation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:locationFoundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    //Move page view to nearest groupe
    [self gotoNearestPage];

    // Abonnement au notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedSucceeded:) name:departuresUpdateSucceededNotification object:nil];

    [self performBlockInBackground:^{
        [self.departuresManager refreshDepartures:self.managedObjectContext.trips];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    //Désabonnement aux notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:departuresUpdateSucceededNotification object:nil];
}

#pragma mark - scrolling
- (void)scrollToPage:(Group*)targetGroup {
    //Get current page
    Group* currentGroup = ((DeparturesNavigationController*)[self viewControllers][0]).group;
    if (targetGroup != currentGroup) {
        //Define next group
        NSArray* groups = [self.managedObjectContext allGroups];
        int currentGroupIndex = [groups indexOfObject:currentGroup];
        int targetGroupIndex = [groups indexOfObject:targetGroup];
        Group* nextGroup = (targetGroupIndex > currentGroupIndex)?groups[currentGroupIndex + 1]:groups[currentGroupIndex - 1];
        
        //Compute scrolling direction
        UIPageViewControllerNavigationDirection direction = (targetGroupIndex > currentGroupIndex)?UIPageViewControllerNavigationDirectionForward:UIPageViewControllerNavigationDirectionReverse;
        UIViewController *nextViewController = [self.pageDataSource viewControllerForGroup:nextGroup storyboard:self.storyboard];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak typeof(self) weakSelf = self;
            [self setViewControllers:@[nextViewController] direction:direction animated:YES completion:^(BOOL finished) {
                [weakSelf scrollToPage:targetGroup];
            }];
        });
    }
}

- (void)gotoNearestPage {
    //Get current location
    CLLocation* currentLocation = [self.locationManager currentLocation];

    //Compute nearest group
    NSArray* favoriteGroups = [self.managedObjectContext favoriteGroups];
    if (favoriteGroups.count > 0) {
        NSArray* sortedGroupes = [favoriteGroups sortedArrayUsingComparator:^NSComparisonResult(Group* groupe1, Group* groupe2) {
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
        
        //Move page view to nearest groupe (+ 1 because of near stops group)
        Group* nearestGroup = sortedGroupes[0];
        [self scrollToPage:nearestGroup];
    }
}

#pragma mark - notifications
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    NSLog(@"Application did become active, refreshing");
#warning background pas nécessaire ici ?
    [self performBlockInBackground:^{
        [self.departuresManager refreshDepartures:self.managedObjectContext.trips];
    }];
}

- (void)departuresUpdatedSucceeded:(NSNotification *)notification {
    //Get current page
    Group* currentGroup = ((DeparturesNavigationController*)[[self viewControllers]objectAtIndex:0]).group;
    
    //Scroll to nearest group only if we are not on near stops page
    Group* nearStopGroup = [self.managedObjectContext nearStopGroup];
    if (currentGroup != nearStopGroup) {
        //Move page view to nearest groupe
        [self gotoNearestPage];
    }
}

- (void)locationUpdated:(NSNotification *)notification {
    //Get current page
    Group* currentGroup = ((DeparturesNavigationController*)[[self viewControllers]objectAtIndex:0]).group;
    
    //Scroll to nearest group only if we are not on near stops page
    Group* nearStopGroup = [self.managedObjectContext nearStopGroup];
    if (currentGroup != nearStopGroup) {
        //Move page view to nearest groupe
        [self gotoNearestPage];
    }
}

@end
