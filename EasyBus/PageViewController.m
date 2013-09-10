//
//  PageViewController.m
//  EasyBus
//
//  Created by Benoit on 26/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

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

@synthesize favoritesManager, groupManager, departuresManager, locationManager, staticDataManager;
@synthesize _datasource;

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    _datasource = [[PageViewControllerDatasource alloc] init];
    _datasource.favoritesManager = self.favoritesManager;
    _datasource.departuresManager = self.departuresManager;
    _datasource.staticDataManager = self.staticDataManager;
    _datasource.groupManager = self.groupManager;

    //Set delegate and datasource
    self.delegate = self;
    self.dataSource = _datasource;
    DeparturesViewController *startingViewController = [_datasource viewControllerAtIndex:0 storyboard:self.storyboard];
    startingViewController.departuresManager = self.departuresManager;
    startingViewController.favoritesManager = self.favoritesManager;
    startingViewController.groupManager = self.groupManager;
    startingViewController.staticDataManager = self.staticDataManager;
    [self setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    // Abonnement au notifications des départs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedStarted:) name:@"departuresUpdateStarted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFound:) name:@"locationFound" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //Raffraichissement des données
    NSArray* favorite = [favoritesManager favorites];
    [self.departuresManager refreshDepartures:favorite];

    //Création de la 1ère vue
    [self gotoNearestPage];
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

- (IBAction)unwindFromAlternate:(UIStoryboardSegue *)segue {
    //Rechargement des départs
    NSArray* favorite = [favoritesManager favorites];
    [self.departuresManager refreshDepartures:favorite];
}

@end
