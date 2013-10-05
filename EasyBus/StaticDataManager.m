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
#import "FavoritesManager.h"
#import "Trip.h"
#import "StopTime.h"
#import "RouteStop.h"
#import "Route+RouteWithAdditions.h"

@implementation StaticDataManager
objection_register_singleton(StaticDataManager)

objection_requires(@"managedObjectContext", @"routesCsvReader", @"stopsCsvReader", @"tripsCsvReader", @"stopTimesCsvReader")
@synthesize managedObjectContext, routesCsvReader, stopsCsvReader, tripsCsvReader, stopTimesCsvReader;

#pragma mark file loading method
- (void) reloadDatabase {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    //Delete all routes
    NSArray * routes = [self routes];
    for (NSManagedObject * route in routes) {
        [self.managedObjectContext deleteObject:route];
    }
    
    //Delete all stops
    NSArray * stops = [self stops];
    for (NSManagedObject * stop in stops) {
        [[self managedObjectContext] deleteObject:stop];
    }

    //load data
    [self.routesCsvReader loadData];
    [self.stopsCsvReader loadData];
    [self.tripsCsvReader loadData];
    [self.stopTimesCsvReader loadData];
    [self computeStopsForRoutes];
}

#pragma mark Business methods
- (NSArray*) routes {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    NSManagedObjectModel *managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *request = [managedObjectModel fetchRequestTemplateForName:@"fetchAllRoutes"];

    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (mutableFetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"id" ascending:YES];
    [mutableFetchResults sortUsingDescriptors:@[sortDescriptor]];

    return mutableFetchResults;
}

- (Route*) routeForId:(NSString*)routeId {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    NSManagedObjectModel *managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *request = [managedObjectModel fetchRequestFromTemplateWithName:@"fetchRouteWithId"
                                                                    substitutionVariables:@{@"id" : routeId}];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (mutableFetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
        return nil;
    }
    
    if ([mutableFetchResults count] == 0) {
        return nil;
    }
    else {
        //Should not be more than 1
        return [mutableFetchResults objectAtIndex:0];
    }
    return nil;
}

- (NSArray*) stops {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    NSManagedObjectModel *managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *request = [managedObjectModel fetchRequestTemplateForName:@"fetchAllStops"];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (mutableFetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }
    
    return mutableFetchResults;
}

- (Stop*) stopForId:(NSString*)stopId {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    NSManagedObjectModel *managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *request = [managedObjectModel fetchRequestFromTemplateWithName:@"fetchStopWithId"
                      substitutionVariables:@{@"id" : stopId}];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (mutableFetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }
    
    if ([mutableFetchResults count] == 0) {
        return nil;
    }
    else {
        //Should not be more than 1
        return [mutableFetchResults objectAtIndex:0];
    }
    return nil;
}

// Return the stops for a route and a direction
- (NSArray*) stopsForRoute:(Route*)route direction:(NSString*)direction {
    NSOrderedSet* stops;
    if ([direction isEqual: @"0"]) {
        stops = [route stopsDirectionZero];
    }
    else {
        stops = [route stopsDirectionOne];
    }

    return [stops array];
}

- (void) computeStopsForRoutes {
    //Construction de l'association route/stop
    NSArray* trips = self.tripsCsvReader.trips;
    NSArray* stops = self.stopTimesCsvReader.stops;
    NSMutableSet* routeStops = [[NSMutableSet alloc] init];
    
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
    
    //Mise des relations route-stop
    [routeStops enumerateObjectsUsingBlock:^(RouteStop* routeStop, BOOL *stop) {
        Route* route = [self routeForId:routeStop.routeId];
        Stop* stopEntity = [self stopForId:routeStop.stopId];
        int sequence = [routeStop.stopSequence intValue] - 1;
        NSString* direction = routeStop.directionId;
        [route addStop:stopEntity forDirection:direction andSequence:sequence];
    }];
}

- (UIImage*) pictoForRouteId:(NSString*)routeId {
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Pictogrammes_100\\%i", [routeId intValue]] ofType:@"png"]];
}

@end
