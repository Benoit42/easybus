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
    
    //Delete all routes
    NSArray * routes = [self.staticDataManager routes];
    for (NSManagedObject * route in routes) {
        [self.managedObjectContext deleteObject:route];
    }
    
    //Delete all stops
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
    
    //sauvegarde du contexte
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }

    //clean-up
    [self.routesCsvReader cleanUp];
    [self.stopsCsvReader cleanUp];
    [self.tripsCsvReader cleanUp];
    [self.stopTimesCsvReader cleanUp];
}


// Association route/stop
- (void) matchRoutesAndStops {
    NSSet* routeStopsSet = [self computeRouteStopsSet];
    [self matchRouteStops:routeStopsSet];
}

- (NSSet*) computeRouteStopsSet {
    //Pré-conditions
    NSAssert(self.tripsCsvReader != nil, @"tripsCsvReader should not be nil");
    NSAssert(self.stopTimesCsvReader != nil, @"stopTimesCsvReader should not be nil");
    
    //Préparation des données
    NSArray* trips = self.tripsCsvReader.trips;
    NSArray* stops = self.stopTimesCsvReader.stops;
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
    //Mise des relations route-stop
    [routeStopsSet enumerateObjectsUsingBlock:^(RouteStop* routeStop, BOOL *stop) {
        Route* route = [self.staticDataManager routeForId:routeStop.routeId];
        Stop* stopEntity = [self.staticDataManager stopForId:routeStop.stopId];
        int sequence = [routeStop.stopSequence intValue] - 1;
        NSString* direction = routeStop.directionId;
        [route addStop:stopEntity forDirection:direction andSequence:sequence];
    }];
}

@end
