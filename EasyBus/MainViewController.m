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

@synthesize managedObjectContext, favoritesManager;

#pragma mark - Saturation mémoire
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Init data
    self.favoritesManager = [[FavoritesManager alloc] initWithContext:self.managedObjectContext];
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController* controller = [segue destinationViewController];
    if ([[segue identifier] isEqualToString:@"initFavorite"]) {
        ((FavoriteInitViewController*)controller).managedObjectContext = self.managedObjectContext;
        ((FavoriteInitViewController*)controller).favoritesManager = self.favoritesManager;
    }
    else if ([[segue identifier] isEqualToString:@"showDepartures"]) {
        ((PageViewController*)controller).managedObjectContext = self.managedObjectContext;
        ((PageViewController*)controller).favoritesManager = self.favoritesManager;
    }
}

- (IBAction)unwindFromAlternate:(UIStoryboardSegue *)segue {
    if ([[segue identifier] isEqualToString:@"initFavorite"]) {
        //Rechargement des départs
        NSArray* favorite = [favoritesManager favorites];
        [[DeparturesManager singleton] refreshDepartures:favorite];
        [self performSegueWithIdentifier:@"showDepartures" sender:self];
    }
}

@end
