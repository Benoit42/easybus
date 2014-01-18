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

objection_requires(@"favoritesManager", @"departuresManager", @"staticDataManager", @"staticDataLoader")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];

    //Pré-conditions
    NSParameterAssert(self.favoritesManager != nil);
    NSParameterAssert(self.departuresManager != nil);
    NSParameterAssert(self.staticDataManager != nil);
    NSParameterAssert(self.staticDataLoader != nil);

    // Abonnement au notifications de chargement des données
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadingProgress:) name:dataLoadingProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadingFinished:) name:dataLoadingFinished object:nil];

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
    if ([self.staticDataManager isDataLoaded]) {
        [self performSegueWithIdentifier:@"start" sender:self];
    }
    else {
        [self.staticDataLoader loadDataFromLocalFiles:[[NSBundle mainBundle] bundleURL]];
    }
}

#pragma mark - managing data loading
- (void)dataLoadingProgress:(NSNotification *)notification {
    //TODO : barre de progression
}

- (void)dataLoadingFinished:(NSNotification *)notification {
    //Désabonnement des notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:dataLoadingProgress object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:dataLoadingFinished object:nil];
    
    //Affichage du menu
    [self performSegueWithIdentifier:@"start" sender:self];
}

#pragma mark - refreshing departures
- (void)favoritesUpdated:(NSNotification *)notification {
    //Raffraichissement des départs
    NSArray* favorite = [self.favoritesManager favorites];
    [self.departuresManager refreshDepartures:favorite];
}

@end
