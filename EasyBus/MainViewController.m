//
//  MainViewController.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "NSObject+AsyncPerformBlock.h"
#import "MainViewController.h"
#import "PageViewController.h"
#import "FavoritesManager.h"

@implementation MainViewController

objection_requires(@"favoritesManager", @"departuresManager", @"staticDataManager", @"staticDataLoader")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    //Pré-conditions
    NSParameterAssert(self.favoritesManager != nil);
    NSParameterAssert(self.departuresManager != nil);
    NSParameterAssert(self.staticDataManager != nil);
    NSParameterAssert(self.staticDataLoader != nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Abonnement au notifications de chargement des données
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadingProgress:) name:dataLoadingProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadingFinished:) name:dataLoadingFinished object:nil];
    
    // Abonnement au notifications des favoris
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesUpdated:) name:updateFavorites object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favoritesUpdated:) name:updateGroups object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Check des données
    if ([self.staticDataManager isDataLoaded]) {
        //Affichage des départs
        [self performSegueWithIdentifier:@"start" sender:self];
    }
    else {
        //Chargement des données
        [self.progressBar setProgress:0.0f animated:NO];
        [self.progressBar setHidden:NO];
        [self.staticDataLoader.progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
        [self performBlockInBackground:^{
            [self.staticDataLoader loadDataFromLocalFiles:[[NSBundle mainBundle] bundleURL]];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Désabonnement aux notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - managing data loading
- (void)dataLoadingProgress:(NSNotification *)notification {
    //TODO : barre de progression
}

- (void)dataLoadingFinished:(NSNotification *)notification {
    //Désabonnement des notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:dataLoadingProgress object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:dataLoadingFinished object:nil];

    //Progress
    [self.staticDataLoader.progress removeObserver:self forKeyPath:@"fractionCompleted"];

    [self performBlockOnMainThread:^{
        [self performSegueWithIdentifier:@"start" sender:self];
    }];
}

#pragma mark - refreshing departures
- (void)favoritesUpdated:(NSNotification *)notification {
    //Raffraichissement des départs
    NSArray* favorite = [self.favoritesManager favorites];
    [self.departuresManager refreshDepartures:favorite];
}

#pragma mark - progress view
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        [self performBlockOnMainThread:^{
            [self.progressBar setProgress:self.staticDataLoader.progress.fractionCompleted animated:YES];
        }];
    }
}


@end
