//
//  NearStopsNavigationController.m
//  EasyBus
//
//  Created by Benoit on 07/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "NearStopsNavigationController.h"
#import "NSManagedObjectContext+Network.h"
#import "NSManagedObjectContext+Group.h"
#import "NSManagedObjectContext+Trip.h"
#import "DeparturesTableViewController.h"

@implementation NearStopsNavigationController
objection_requires(@"managedObjectContext", @"departuresManager", @"locationManager")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
    
    NSParameterAssert(self.managedObjectContext);
    NSParameterAssert(self.departuresManager);
    NSParameterAssert(self.locationManager);
}

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    //Abonnement aux notification de géolocalisation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:locationFoundNotification object:nil];
    
    //Récupération du groupe
    ProximityGroup* proximityGroup = [self updateProximityGroup];
    
    //Mise à jour de la table view
    DeparturesTableViewController* departuresTableViewController = (DeparturesTableViewController*)self.viewControllers[0];
    departuresTableViewController.group = proximityGroup;
    
    //Super à la fin pour pouvoir setter le groupe avant l'affichage de la table
    [super viewWillAppear:animated];
}

- (void) dealloc {
    //Désabonnement aux notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)locationUpdated:(NSNotification *)notification {
    //Récupération du groupe
    ProximityGroup* proximityGroup = [self updateProximityGroup];
    
    //Mise à jour de la table view
    DeparturesTableViewController* departuresTableViewController = (DeparturesTableViewController*)self.viewControllers[0];
    departuresTableViewController.group = proximityGroup;
}

- (ProximityGroup*)updateProximityGroup {
    //Get location
    CLLocation* here = self.locationManager.location;
    
    //Mise à jour du groupe (suppression des trips associés)
    ProximityGroup* proximityGroup = [self.managedObjectContext updateProximityGroupForLocation:here];
    
    //Retour
    return proximityGroup;
}

@end
