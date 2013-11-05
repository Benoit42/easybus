//
//  PageViewController.m
//  EasyBus
//
//  Created by Benoit on 26/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "NSObject+AsyncPerformBlock.h"
#import "PageViewController.h"
#import "PageViewControllerDatasource.h"
#import "DeparturesViewController.h"
#import "FavoritesNavigationController.h"
#import "LocationManager.h"
#import "Stop.h"

@interface PageViewController()

@property(nonatomic) PageViewControllerDatasource* _datasource;

@end

@implementation PageViewController

objection_requires(@"favoritesManager", @"groupManager", @"departuresManager", @"locationManager")
@synthesize favoritesManager, groupManager, departuresManager, locationManager, _datasource;

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Pré-conditions
    NSAssert(self.favoritesManager != nil, @"favoritesManager should not be nil");
    NSAssert(self.groupManager != nil, @"groupManager should not be nil");
    NSAssert(self.departuresManager != nil, @"departuresManager should not be nil");
    NSAssert(self.locationManager != nil, @"locationManager should not be nil");

	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    _datasource = [[JSObjection defaultInjector] getObject:[PageViewControllerDatasource class]];

    //Set delegate and datasource
    self.delegate = self;
    self.dataSource = _datasource;
    DeparturesViewController *startingViewController = [_datasource viewControllerAtIndex:0 storyboard:self.storyboard];
    [self setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    // Abonnement au notifications des départs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedStarted:) name:departuresUpdateStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFound:) name:locationFound object:nil];

    // Abonnement au notifications des favoris
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesUpdated:) name:updateFavorites object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesUpdated:) name:updateGroups object:nil];

    // Couleur de fond vert Star
    self.view.backgroundColor = [UIColor colorWithRed:42.0f/255.0f green:231.0f/255.0f blue:185.0f/255.0f alpha:1.0f];
}

- (void)viewDidDisappear:(BOOL)animated {
    //Stop GPS
    [self.locationManager stopUpdatingLocation];
}

- (void)scrollToPage:(NSInteger)page {
    //Get current page
    int currentPage = ((DeparturesViewController*)[[self viewControllers]objectAtIndex:0]).page;
    if (page != currentPage) {
        int increment = (page>currentPage)?1:-1;
        int nextPage = currentPage+increment;
        UIPageViewControllerNavigationDirection direction = (increment == 1)?UIPageViewControllerNavigationDirectionForward:UIPageViewControllerNavigationDirectionReverse;
        UIViewController *currentViewController = [_datasource viewControllerAtIndex:currentPage storyboard:self.storyboard];
        for (int i=nextPage; i!=page+increment; i+=increment) {
            //Move to page
            UIViewController *nextViewController;
            if (increment == 1) {
                nextViewController = [_datasource pageViewController:self viewControllerAfterViewController:currentViewController];
            }
            else {
                nextViewController = [_datasource pageViewController:self viewControllerBeforeViewController:currentViewController];
                
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
    NSArray* groupes = [groupManager groups];
    double minDistance = MAXFLOAT;
    int index = -1;
    for (int i=0; i<[groupes count]; i++) {
        Group* groupe = [groupes objectAtIndex:i];
        Favorite* firstFavorite = [[groupe favorites] objectAtIndex:0];
        CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:[firstFavorite.stop.latitude doubleValue] longitude:[firstFavorite.stop.longitude doubleValue]];
        CLLocationDistance currentDistance = [stopLocation distanceFromLocation:currentLocation];
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
    [locationManager startUpdatingLocation];
}

#pragma mark - Notification de localisation
- (void)locationFound:(NSNotification *)notification {
    //Move page view to nearest groupe
    [self gotoNearestPage];
}

#pragma mark - refreshing departures
- (void)favoritesUpdated:(NSNotification *)notification {
    NSArray* favorite = [favoritesManager favorites];
    [self.departuresManager refreshDepartures:favorite];
}

@end
