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
#import "FavoritesManager.h"
#import "LocationManager.h"

@interface PageViewController()

@property(nonatomic) PageViewControllerDatasource* _datasource;

@end

@implementation PageViewController

@synthesize _datasource;

//constructeur
- (void)viewDidLoad {
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    _datasource = [PageViewControllerDatasource new];

    //Set delegate and datasource
    self.delegate = self;
    self.dataSource = _datasource;
    DeparturesViewController *startingViewController = [_datasource viewControllerAtIndex:0 storyboard:self.storyboard];
    [self setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    // Abonnement au notifications des départs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFound:) name:@"locationFound" object:nil];
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
    //Création de la 1ère vue
    [self gotoNearestPage];
}


- (void)gotoPage:(NSInteger)page {
    //Move to page
    DeparturesViewController *viewController = [_datasource viewControllerAtIndex:page storyboard:self.storyboard];
    [self setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
}

- (void)gotoNearestPage {
    //Get location
    CLLocation* currentLocation = [[LocationManager singleton] currentLocation];

    //Compute nearest group
    NSArray* groupes = [[FavoritesManager singleton] groupes];
    double minDistance = MAXFLOAT;
    int index = -1;
    for (int i=0; i<[groupes count]; i++) {
        Favorite* groupe = [groupes objectAtIndex:i];
        CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:groupe.lat longitude:groupe.lon];
        CLLocationDistance currentDistance = [stopLocation distanceFromLocation:currentLocation];
        if (currentDistance < minDistance) {
            index = i;
            minDistance = currentDistance;
        }
    }
    
    //Move page view to nearest groupe
    [self gotoPage:index];
}

#pragma mark - Notification de localistion
- (void)locationFound:(NSNotification *)notification {
    //Move page view to nearest groupe
    [self gotoNearestPage];
}

@end
