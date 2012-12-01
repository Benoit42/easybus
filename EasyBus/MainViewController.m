//
//  MainViewController.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "MainViewController.h"
#import "FavoritesNavigationController.h"
#import "PageViewController.h"

@implementation MainViewController

@synthesize _refreshDate, _containerView, _pageViewController, _noFavoritesViewController;

#pragma mark - Saturation mémoire
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alerte mémoire" message:@"Dans MainViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
}

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Création de la 1ère vue
    NSArray* favorites = [[FavoritesManager singleton] favorites];
    if ([favorites count] > 0 ) {
        if (_pageViewController == nil) {
            //Création de la 1ère vue
            _pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];

            // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
            CGRect pageViewRect = _containerView.bounds;
            _pageViewController.view.frame = pageViewRect;
        }
        [self addChildViewController:_pageViewController];
        [_containerView addSubview:_pageViewController.view ];
        
        //ecran de démarrage sans favoris
        [_noFavoritesViewController removeFromParentViewController];
        [_noFavoritesViewController.view removeFromSuperview];
    }
    else {
        //ecran de démarrage sans favoris
        [_pageViewController removeFromParentViewController];
        [_pageViewController.view removeFromSuperview];
        
        if (_noFavoritesViewController == nil) {
            _noFavoritesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NoFavoritesViewController"];
        }
        [self addChildViewController:_noFavoritesViewController];
        [_containerView addSubview:_noFavoritesViewController.view];
    }
}

#pragma mark - Segues
- (IBAction)unwindFromAlternate:(UIStoryboardSegue *)segue {
    //Rechargement des départs
    NSArray* favorite = [[FavoritesManager singleton] favorites];
    [[DeparturesManager singleton] refreshDepartures:favorite];
}

@end
