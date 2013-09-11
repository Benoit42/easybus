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
#import "FavoriteInitViewController.h"
#import "FavoritesManager.h"

@implementation MainViewController

@synthesize managedObjectContext, favoritesManager, groupManager, departuresManager, staticDataManager, locationManager;

#pragma mark - Saturation mémoire
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Check des données statiques
    if ([[self.staticDataManager routes] count] == 0) {
        [self.staticDataManager reloadDatabase];
    }
    
    //Check des favoris
    NSArray* favorites = [favoritesManager favorites];
    if ([favorites count] == 0 ) {
        //ecran de démarrage sans favoris
        [self performSegueWithIdentifier:@"initFavorite" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"showDepartures" sender:self];
    }
}

#pragma mark - Segues
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController* controller = [segue destinationViewController];
    if ([[segue identifier] isEqualToString:@"initFavorite"]) {
        ((FavoriteInitViewController*)controller).staticDataManager = self.staticDataManager;
        ((FavoriteInitViewController*)controller).favoritesManager = self.favoritesManager;
        ((FavoriteInitViewController*)controller).groupManager = self.groupManager;
    }
    else if ([[segue identifier] isEqualToString:@"showDepartures"]) {
        ((PageViewController*)controller).staticDataManager = self.staticDataManager;
        ((PageViewController*)controller).favoritesManager = self.favoritesManager;
        ((PageViewController*)controller).groupManager = self.groupManager;
        ((PageViewController*)controller).departuresManager = self.departuresManager;
        ((PageViewController*)controller).locationManager = self.locationManager;
    }
}

- (IBAction)unwindFromAlternate:(UIStoryboardSegue *)segue {
    if ([[segue identifier] isEqualToString:@"initFavorite"]) {
        //Rechargement des départs
        NSArray* favorite = [favoritesManager favorites];
        [departuresManager refreshDepartures:favorite];
        [self performSegueWithIdentifier:@"showDepartures" sender:self];
    }
}

@end
