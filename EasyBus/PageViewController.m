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
#import "FavoritesManager.h"

@interface PageViewController()

@property(nonatomic) PageViewControllerDatasource* _datasource;

@end

@implementation PageViewController
objection_requires(@"groupManager", @"locationManager", @"pageDataSource")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Pré-conditions
    NSParameterAssert(self.groupManager != nil);
    NSParameterAssert(self.locationManager != nil);
    NSParameterAssert(self.pageDataSource != nil);

    //Set delegate and datasource
    self.delegate = self;
    self.dataSource = self.pageDataSource;
//    UIViewController *startingViewController = [self.pageDataSource viewControllerAtIndex:0 storyboard:self.storyboard];
//    [self setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    // Abonnement au notifications des favoris
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesUpdated:) name:updateFavorites object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesUpdated:) name:updateGroups object:nil];

    // Abonnement au notifications de localisation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFound:) name:locationFound object:nil];

    // Couleur de fond vert Star
    self.view.backgroundColor = Constants.starGreenColor;
}

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
    NSArray* groupes = [self.groupManager groups];
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

#pragma mark - favorite or group updated
- (void)favoritesUpdated:(NSNotification *)notification {
    [self performBlockOnMainThread:^{
        //Rechargement des pages
        DeparturesViewController* currentPage = (DeparturesViewController*)[[self viewControllers]objectAtIndex:0];
        [self setViewControllers:@[currentPage] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }];
}

#pragma mark - Notification de localisation
- (void)locationFound:(NSNotification *)notification {
    [self performBlockOnMainThread:^{
        //Move page view to nearest groupe
        [self gotoNearestPage];
    }];
}

@end
