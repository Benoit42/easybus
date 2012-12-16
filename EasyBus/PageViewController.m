//
//  PageViewController.m
//  EasyBus
//
//  Created by Benoit on 26/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "PageViewController.h"
#import "DeparturesViewController.h"
#import "FavoritesManager.h"
#import "LocationManager.h"

@interface PageViewController()

@property(nonatomic) NSMutableArray* _departuresViewControlers;

@end

@implementation PageViewController

@synthesize currentPage, _departuresViewControlers;

//constructeur
- (void)viewDidLoad {
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    _departuresViewControlers = [NSMutableArray new];

    //Set delegate and datasource
    self.delegate = self;
    self.dataSource = self;
    self.currentPage = -1;
    
    // Abonnement au notifications des départs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFound:) name:@"locationFound" object:nil];
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Création de la 1ère vue
    [self gotoPage:0];
//    DeparturesViewController *departuresViewController =  [self getDeparturesViewController:currentPage];
//    [self setViewControllers:@[departuresViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
}

#pragma mark - Page View Controller Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    //get current view controller index
    NSUInteger index = [_departuresViewControlers indexOfObject:viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    //get previous view controller
    int page = ((DeparturesViewController*)viewController).page;
    DeparturesViewController *previousViewController =  [self getDeparturesViewController:page - 1];
    return previousViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    //get current view controller index
    NSUInteger index = [self._departuresViewControlers indexOfObject:viewController];
    if (index == NSNotFound) {
        //impossible en principe, c'est une erreur
        return nil;
    }
    
    //get next view controller
    int page = ((DeparturesViewController*)viewController).page;
    DeparturesViewController *nextViewController =  [self getDeparturesViewController:page + 1];
    return nextViewController;
}

- (DeparturesViewController*)getDeparturesViewController:(NSInteger)index {
    DeparturesViewController* viewController = nil;
    if (index < [[[FavoritesManager singleton] groupes] count]) {
        if (index < [_departuresViewControlers count]) {
            //Le view controler existe déjà
            viewController = [_departuresViewControlers objectAtIndex:index];
        }
    
        if (viewController == nil) {
            //Le view controler n'existe pas encore
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DeparturesViewController"];
            ((DeparturesViewController*)viewController).page = index;
            [_departuresViewControlers insertObject:viewController atIndex:index];
        }
    }

    return viewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [[[FavoritesManager singleton] groupes] count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    if ([pageViewController.viewControllers count] > 0) 
        return ((DeparturesViewController*)[pageViewController.viewControllers objectAtIndex:0]).page;
    else
        return 0;
}

#pragma mark - Page View Controller Data Source
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        currentPage = ((DeparturesViewController*)[pageViewController.viewControllers objectAtIndex:0]).page;
    }
}

#pragma mark - Notification de localisation
- (void)gotoPage:(NSInteger)page {
    DeparturesViewController *departuresViewController =  [self getDeparturesViewController:page];
    [self setViewControllers:@[departuresViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)locationFound:(NSNotification *)notification {
    //Get location
    CLLocation* currentLocation = [[LocationManager singleton] currentLocation];
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          currentLocation.coordinate.latitude,
          currentLocation.coordinate.longitude);
    
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

@end
