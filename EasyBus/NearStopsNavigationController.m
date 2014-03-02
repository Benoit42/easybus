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
    
    //Get nearest stops having same name
    CLLocation* here = [self.locationManager currentLocation];

    //Nettoyage du groupe
    Group* nearStopGroup = [self.managedObjectContext nearStopGroup];
    if (!nearStopGroup) {
        //Création du groupe des arrêts proches
#warning mettre ce code dans l'opération de migration des données
        nearStopGroup = [self.managedObjectContext addGroupWithName:@"à proximité" isNearStopGroup:YES];
    }
    [nearStopGroup removeTrips:[nearStopGroup trips]];

    if (here) {
        //Calcul des arrêts proches
        NSArray* stops = [self.managedObjectContext nearestStopsHavingSameNameFrom:here];
        
        //Set trips in group
        nearStopGroup.name = (stops.count > 0)?((Stop*)stops[0]).name:@"à proximité";
        [stops enumerateObjectsUsingBlock:^(Stop* selectedStop, NSUInteger idx, BOOL *stop) {
            [selectedStop.routesDirectionZero enumerateObjectsUsingBlock:^(Route* route, BOOL *stop) {
                Trip* trip = [self.managedObjectContext addTrip:route stop:selectedStop direction:@"0"];
                [nearStopGroup addTripsObject:trip];
            }];
            [selectedStop.routesDirectionOne enumerateObjectsUsingBlock:^(Route* route, BOOL *stop) {
                Trip* trip = [self.managedObjectContext addTrip:route stop:selectedStop direction:@"1"];
                [nearStopGroup addTripsObject:trip];
            }];
        }];        
    }
    else {
        //Pas de géoloc obtenue
        nearStopGroup.name = @"position inconnue";
    }

    //Show departures
    DeparturesTableViewController* departuresTableViewController = (DeparturesTableViewController*)self.viewControllers[0];
    departuresTableViewController.group = nearStopGroup;

    //Super à la fin pour pouvoir setter le groupe avant l'affichage de la table 
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Désabonnement aux notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)locationUpdated:(NSNotification *)notification {
    [self performBlockOnMainThread:^{
        //Refresh departures
        DeparturesTableViewController* departuresTableViewController = (DeparturesTableViewController*)self.viewControllers[0];

        //refresh table view
        [departuresTableViewController.tableView reloadData];
    }];
}

@end
