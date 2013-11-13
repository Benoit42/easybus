//
//  MainViewController.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "MainViewController.h"
#import "PageViewController.h"
#import "FavoritesManager.h"

@implementation MainViewController

objection_requires(@"favoritesManager", @"departuresManager", @"staticDataManager", @"locationManager")
@synthesize favoritesManager, departuresManager, staticDataManager, locationManager;

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];

    //Pré-conditions
    NSAssert(self.favoritesManager != nil, @"favoritesManager should not be nil");
    NSAssert(self.departuresManager != nil, @"departuresManager should not be nil");
    NSAssert(self.staticDataManager != nil, @"staticDataManager should not be nil");
    NSAssert(self.locationManager != nil, @"locationManager should not be nil");

    // Abonnement au notifications des départs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedStarted:) name:departuresUpdateStarted object:nil];

    // Abonnement au notifications des favoris
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesUpdated:) name:updateFavorites object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesUpdated:) name:updateGroups object:nil];
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Check des données statiques
    [self performSegueWithIdentifier:@"start" sender:self];
//    if ([self.staticDataManager] isDataLoaded]) {
//        [self performSegueWithIdentifier:@"showDepartures" sender:self];
//    }
//    else {
//        charger ici les données avec une barre de progression
//    }
}

#pragma mark - refreshing departures
- (void)favoritesUpdated:(NSNotification *)notification {
    //Raffraichissement des départs
    NSArray* favorite = [self.favoritesManager favorites];
    [self.departuresManager refreshDepartures:favorite];
}

#pragma mark - refreshing location
- (void)departuresUpdatedStarted:(NSNotification *)notification {
    [self.locationManager startUpdatingLocation];
}

@end
