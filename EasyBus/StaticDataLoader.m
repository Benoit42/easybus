//
//  StaticDataManager.m
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CoreData/CoreData.h>
#import "StaticDataManager.h"
#import "StaticDataLoader.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"
#import "RouteStop.h"
#import "Route+RouteWithAdditions.h"

@implementation StaticDataLoader
objection_register_singleton(StaticDataLoader)

objection_requires(@"managedObjectContext", @"staticDataManager", @"routesCsvReader", @"stopsCsvReader", @"tripsCsvReader", @"stopTimesCsvReader")
@synthesize managedObjectContext, staticDataManager, routesCsvReader, stopsCsvReader, tripsCsvReader, stopTimesCsvReader;

#pragma mark file loading method
- (void) loadStaticData {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    NSAssert(self.staticDataManager != nil, @"staticDataManager should not be nil");
    NSAssert(self.routesCsvReader != nil, @"routesCsvReader should not be nil");
    NSAssert(self.stopsCsvReader != nil, @"stopsCsvReader should not be nil");
    NSAssert(self.tripsCsvReader != nil, @"tripsCsvReader should not be nil");
    NSAssert(self.stopTimesCsvReader != nil, @"managedObjectContext should not be nil");
    
    //Log
    NSLog(@"Démarrage du chargement des données");
    
    //Delete all routes
    NSLog(@"Suppression des routes");
    NSArray * routes = [self.staticDataManager routes];
    for (NSManagedObject * route in routes) {
        [self.managedObjectContext deleteObject:route];
    }
    
    //Delete all stops
    NSLog(@"Suppression des arrêts");
    NSArray * stops = [self.staticDataManager stops];
    for (NSManagedObject * stop in stops) {
        [self.managedObjectContext deleteObject:stop];
    }
    
    //load data
    [self.routesCsvReader loadData];
    [self.stopsCsvReader loadData];
    [self.tripsCsvReader loadData];
    [self.stopTimesCsvReader loadData];
    [self matchRoutesAndStops];
    
    //clean-up
    [self.routesCsvReader cleanUp];
    [self.stopsCsvReader cleanUp];
    [self.tripsCsvReader cleanUp];
    [self.stopTimesCsvReader cleanUp];

    //Log
    NSLog(@"Fin du chargement des données");
}


// Association route/stop
- (void) matchRoutesAndStops {
    NSMutableSet* routeStopsSet = [self computeRouteStopsSet];
    [self matchRouteStops:routeStopsSet];
}

- (NSMutableSet*) computeRouteStopsSet {
    //Pré-conditions
    NSAssert(self.tripsCsvReader != nil, @"tripsCsvReader should not be nil");
    NSAssert(self.stopTimesCsvReader != nil, @"stopTimesCsvReader should not be nil");
    
    //Log
    NSLog(@"Association route/arrêts 1/2");

    //Préparation des données
    NSArray* trips = self.tripsCsvReader.trips;
    [trips sortedArrayUsingComparator:^NSComparisonResult(Trip* trip1, Trip* trip2) {
        return [trip1.id compare:trip2.id];
    }];
    NSArray* stops = self.stopTimesCsvReader.stops;
    [stops sortedArrayUsingComparator:^NSComparisonResult(StopTime* st1, StopTime* st2) {
        return [st1.tripId compare:st2.tripId];
    }];
    NSMutableSet* routeStops = [[NSMutableSet alloc] init];
    
    //Matching route/stop
    int i=0, j=0;
    while (i < trips.count) {
        Trip* trip = trips[i];
        while (j < stops.count) {
            StopTime* stopTime = stops[j];
            if ([trip.id compare:stopTime.tripId] == NSOrderedAscending) {
                break;
            }
            else if ([trip.id compare:stopTime.tripId] == NSOrderedDescending) {
                continue;
            }
            else {
                //Les tripId matchent
                RouteStop* routeStop = [[RouteStop alloc] init];
                routeStop.routeId = trip.routeId;
                routeStop.directionId = trip.directionId;
                routeStop.stopId = stopTime.stopId;
                routeStop.stopSequence = stopTime.stopSequence;
                [routeStops addObject:routeStop];
                
                //Incrément de boucle
                j++;
            }
        }
        
        //Incrément de boucle
        i++;
    }
    
    //Retour
    return routeStops;
}

// Association route/stop
- (void) matchRouteStops:(NSSet*)routeStopsSet {
    //Log
    NSLog(@"Association route/arrêts 2/2");
    
    //Pre-fetching
    NSMutableDictionary* routesDictionnary = [[NSMutableDictionary alloc] init];
    [self.staticDataManager.routes enumerateObjectsUsingBlock:^(Route* route, NSUInteger idx, BOOL *stop) {
        [routesDictionnary setObject:route forKey:route.id];
    }];
    
    NSMutableDictionary* stopsDictionnary = [[NSMutableDictionary alloc] init];
    [self.staticDataManager.stops enumerateObjectsUsingBlock:^(Stop* stopEntity, NSUInteger idx, BOOL *stop) {
        [stopsDictionnary setObject:stopEntity forKey:stopEntity.id];
    }];
    
    //Mise des relations route-stop
    [routeStopsSet enumerateObjectsUsingBlock:^(RouteStop* routeStop, BOOL *stop) {
        Route* route = [routesDictionnary objectForKey:routeStop.routeId];
        Stop* stopEntity = [stopsDictionnary objectForKey:routeStop.stopId];
        NSString* direction = routeStop.directionId;
        StopSequence* stopSequence = (StopSequence *)[NSEntityDescription insertNewObjectForEntityForName:@"StopSequence" inManagedObjectContext:self.managedObjectContext];
        stopSequence.sequence = routeStop.stopSequence;
        stopSequence.stop = stopEntity;
        [route addStop:stopSequence forDirection:direction];
    }];
}

@end
