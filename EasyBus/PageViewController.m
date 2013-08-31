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
#import "FavoritesManager.h"
#import "LocationManager.h"
#import "Stop.h"

@interface PageViewController()

@property(nonatomic) PageViewControllerDatasource* _datasource;

@end

@implementation PageViewController

@synthesize managedObjectContext, favoritesManager;
@synthesize _datasource;

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    _datasource = [PageViewControllerDatasource alloc];
    _datasource.favoritesManager = self.favoritesManager;

    //Set delegate and datasource
    self.delegate = self;
    self.dataSource = _datasource;
    DeparturesViewController *startingViewController = [_datasource viewControllerAtIndex:0 storyboard:self.storyboard];
    [self setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    // Abonnement au notifications des départs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFound:) name:@"locationFound" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //Création de la 1ère vue
    [self gotoNearestPage];
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
    CLLocation* currentLocation = [[LocationManager singleton] currentLocation];

    //Compute nearest group
    NSArray* groupes = [favoritesManager groupes];
    double minDistance = MAXFLOAT;
    int index = -1;
    for (int i=0; i<[groupes count]; i++) {
        Favorite* groupe = [groupes objectAtIndex:i];
        CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:[groupe.stop.latitude doubleValue] longitude:[groupe.stop.longitude doubleValue]];
        CLLocationDistance currentDistance = [stopLocation distanceFromLocation:currentLocation];
        if (currentDistance < minDistance) {
            index = i;
            minDistance = currentDistance;
        }
    }
    
    //Move page view to nearest groupe
    [self scrollToPage:index];
}

#pragma mark - Notification de localisation
- (void)locationFound:(NSNotification *)notification {
    //Move page view to nearest groupe
    [self gotoNearestPage];
}

- (IBAction)unwindFromAlternate:(UIStoryboardSegue *)segue {
    //Rechargement des départs
    NSArray* favorite = [favoritesManager favorites];
    [[DeparturesManager singleton] refreshDepartures:favorite];
}

#pragma mark - Segues
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addFavorite"])
    {
        FavoritesNavigationController* destinationViewController = (FavoritesNavigationController*)[segue destinationViewController];
        destinationViewController.managedObjectContext = self.managedObjectContext;
        destinationViewController.favoritesManager = self.favoritesManager;
    }
}


@end
