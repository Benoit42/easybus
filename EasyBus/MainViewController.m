//
//  MainViewController.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "MainViewController.h"
#import "FavoritesNavigationController.h"
#import "PageViewController.h"
#import "FavoriteInitViewController.h"
#import "FavoritesManager.h"

@implementation MainViewController

objection_requires(@"favoritesManager", @"departuresManager", @"staticDataManager", @"locationManager")
@synthesize favoritesManager, departuresManager, staticDataManager, locationManager;

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Saturation mémoire
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];

    //Pré-conditions
    NSAssert(self.favoritesManager != nil, @"favoritesManager should not be nil");
    NSAssert(self.departuresManager != nil, @"departuresManager should not be nil");
    NSAssert(self.staticDataManager != nil, @"staticDataManager should not be nil");
    NSAssert(self.locationManager != nil, @"locationManager should not be nil");
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
- (IBAction)unwindFromAlternate:(UIStoryboardSegue *)segue {
    if ([[segue identifier] isEqualToString:@"initFavorite"]) {
        //Rechargement des départs
        NSArray* favorite = [favoritesManager favorites];
        [departuresManager refreshDepartures:favorite];
        [self performSegueWithIdentifier:@"showDepartures" sender:self];
    }
}

@end
