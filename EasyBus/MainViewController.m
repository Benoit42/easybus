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
#import "NSManagedObjectContext+Network.h"
#import "NSManagedObjectContext+Trip.h"
#import "NSManagedObjectContext+Group.h"

#define RELOAD_KEOLIS_DATA_KEY @"reload_keolis_data"

@implementation MainViewController
objection_requires(@"managedObjectContext", @"departuresManager", @"staticDataLoader")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
    NSParameterAssert(self.departuresManager != nil);
    NSParameterAssert(self.staticDataLoader != nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Abonnement au notifications de chargement des données
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadingProgress:) name:dataLoadingProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadingFinished:) name:dataLoadingFinished object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Check des données
    if ([self needsToLoadData]) {
        //Chargement des données
//        [self.progressBar setProgress:0.0f animated:NO];
//        [self.progressBar setHidden:NO];
        [self.staticDataLoader.progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
        [self.staticDataLoader loadDataFromLocalFiles:[[NSBundle mainBundle] bundleURL]];
    }
    else {
        //Affichage des départs
        [self performSegueWithIdentifier:@"start" sender:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Désabonnement aux notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:dataLoadingFinished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:dataLoadingProgress object:nil];
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

#pragma mark - progress view
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        [self performBlockOnMainThread:^{
            [self.progressBar setProgress:self.staticDataLoader.progress.fractionCompleted animated:YES];
        }];
    }
}

#pragma mark - progress view
//Test de rechargement des données GTFS
- (BOOL)needsToLoadData {
    BOOL feedInfoOk = [self.managedObjectContext feedInfo] != nil;
    BOOL terminusOk = [self terminusLabelIsOk];
    BOOL reloadPreferenceEnabled = [self reloadPreferenceIsOk];
    BOOL needsToCleanupEmptyRoutes = [self needsToCleanupEmptyRoutes];
    return !feedInfoOk || !terminusOk || reloadPreferenceEnabled || needsToCleanupEmptyRoutes ;
}

//Test pour déclencher le chargement des données GTFS corrigeant le bugs des terminus
- (BOOL)terminusLabelIsOk {
    Route* route200 = [self.managedObjectContext routeForId:@"0200"];
    BOOL route200Ok = [route200.fromName isEqualToString:@"Rennes Lycée Assomption"];
    return route200Ok;
}

- (BOOL)reloadPreferenceIsOk {
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    BOOL reloadPreferenceOk = [[defaults valueForKey:RELOAD_KEOLIS_DATA_KEY] boolValue];
    [defaults setValue:NO forKey:RELOAD_KEOLIS_DATA_KEY];
    return reloadPreferenceOk;
}

#warning A supprimer quand tous les utilisateurs seront passé en 1.1
- (BOOL)needsToCleanupEmptyRoutes {
    //Get route 63
    Route* route63 = [self.managedObjectContext routeForId:@"0063"];
    return route63 != nil;
}

@end
