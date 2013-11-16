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

NSString *const dataLoadingProgress = @"dataLoadingProgress";
NSString *const dataLoadingFinished = @"dataLoadingFinished";

@implementation StaticDataLoader
objection_register_singleton(StaticDataLoader)

objection_requires(@"managedObjectContext", @"staticDataManager", @"routesCsvReader", @"stopsCsvReader", @"tripsCsvReader", @"stopTimesCsvReader", @"routesStopsCsvReader")

#pragma mark file loading method
- (void)loadDataFromWeb:(NSURL*)directory {
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
    NSParameterAssert(self.staticDataManager != nil);
    NSParameterAssert(self.routesCsvReader != nil);
    NSParameterAssert(self.stopsCsvReader != nil);
    NSParameterAssert(self.tripsCsvReader != nil);
    NSParameterAssert(self.stopTimesCsvReader != nil);
    
    //Log
    NSLog(@"Démarrage du chargement des données web");
    
    //load data
    NSURL* routesUrl = [NSURL URLWithString:@"routes.txt" relativeToURL:directory];
    [self.routesCsvReader loadData:routesUrl];
    NSURL* additionnalsRoutesUrl = [NSURL URLWithString:@"routes_additionals.txt" relativeToURL:directory];
    [self.routesCsvReader loadData:additionnalsRoutesUrl];
    NSURL* stopsUrl = [NSURL URLWithString:@"stops.txt" relativeToURL:directory];
    [self.stopsCsvReader loadData:stopsUrl];
    NSURL* tripsUrl = [NSURL URLWithString:@"trips.txt" relativeToURL:directory];
    [self.tripsCsvReader loadData:tripsUrl];
    NSURL* stopTimesUrl = [NSURL URLWithString:@"stop_times.txt" relativeToURL:directory];
    [self.stopTimesCsvReader loadData:stopTimesUrl];
    [self matchTrips:self.tripsCsvReader.trips andStops:self.stopTimesCsvReader.stops];
    
    //clean-up
    [self.routesCsvReader cleanUp];
    [self.stopsCsvReader cleanUp];
    [self.tripsCsvReader cleanUp];
    [self.stopTimesCsvReader cleanUp];
    
    //Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:dataLoadingFinished object:self];

    //Log
    NSLog(@"Fin du chargement des données web");
}

#pragma mark file loading method
- (void)loadDataFromLocalFiles:(NSURL*)directory {
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
    NSParameterAssert(self.staticDataManager != nil);
    NSParameterAssert(self.routesCsvReader != nil);
    NSParameterAssert(self.stopsCsvReader != nil);
    NSParameterAssert(self.routesStopsCsvReader != nil);
    
    //Log
    NSLog(@"Démarrage du chargement des données locales");
    
    //load data
    NSURL* routesUrl = [NSURL URLWithString:@"routes.txt" relativeToURL:directory];
    [self.routesCsvReader loadData:routesUrl];
    NSURL* additionnalsRoutesUrl = [NSURL URLWithString:@"routes_additionals.txt" relativeToURL:directory];
    [self.routesCsvReader loadData:additionnalsRoutesUrl];
    NSURL* stopsUrl = [NSURL URLWithString:@"stops.txt" relativeToURL:directory];
    [self.stopsCsvReader loadData:stopsUrl];
    NSURL* routesStops = [NSURL URLWithString:@"routes_stops.txt" relativeToURL:directory];
    [self.routesStopsCsvReader loadData:routesStops];
    [self matchRoutesAndStops:self.routesStopsCsvReader.routesStops];
    
    //clean-up
    [self.routesCsvReader cleanUp];
    [self.stopsCsvReader cleanUp];
    [self.routesStopsCsvReader cleanUp];
    
    //Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:dataLoadingFinished object:self];
    
    //Log
    NSLog(@"Fin du chargement des données locales");
}

// Association route/stop
- (void) matchTrips:(NSArray*)trips andStops:(NSArray*)stops {
    //Pré-conditions
    NSAssert(trips != nil, @"tripsCsvReader should not be nil");
    NSAssert(stops != nil, @"stopTimesCsvReader should not be nil");
    
    //Log
    NSLog(@"Association route/arrêts");

    //Préparation des données
    trips = [trips sortedArrayUsingComparator:^NSComparisonResult(Trip* trip1, Trip* trip2) {
        return [trip1.id compare:trip2.id];
    }];
    stops = [stops sortedArrayUsingComparator:^NSComparisonResult(StopTime* st1, StopTime* st2) {
        NSComparisonResult compareTrips = [st1.tripId compare:st2.tripId];
        if (compareTrips == NSOrderedSame) {
            return [st1.stopSequence compare:st2.stopSequence];
        }
        else {
            return compareTrips;
        }
    }];
    
    //Pre-fetching
    NSMutableDictionary* routesDictionnary = [[NSMutableDictionary alloc] init];
    [self.staticDataManager.routes enumerateObjectsUsingBlock:^(Route* route, NSUInteger idx, BOOL *stop) {
        [routesDictionnary setObject:route forKey:route.id];
    }];
    
    NSMutableDictionary* stopsDictionnary = [[NSMutableDictionary alloc] init];
    [self.staticDataManager.stops enumerateObjectsUsingBlock:^(Stop* stopEntity, NSUInteger idx, BOOL *stop) {
        [stopsDictionnary setObject:stopEntity forKey:stopEntity.id];
    }];
    
    
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
                Route* route = [routesDictionnary objectForKey:trip.routeId];
                Stop* stop = [stopsDictionnary objectForKey:stopTime.stopId];
                NSString* direction = trip.directionId;
                NSNumber* sequence = stopTime.stopSequence;
                [route addStop:stop forSequence:sequence forDirection:direction];
                
                //Incrément de boucle
                j++;
            }
        }
        
        //Incrément de boucle
        i++;
    }
    
    //Retour
    return;
}

- (void) matchRoutesAndStops:(NSArray*)routeStops {
    //Pré-conditions
    NSParameterAssert(routeStops != nil);
    
    //Log
    NSLog(@"Association route/arrêts");
    
    //Pre-fetching
    NSMutableDictionary* routesDictionnary = [[NSMutableDictionary alloc] init];
    [self.staticDataManager.routes enumerateObjectsUsingBlock:^(Route* route, NSUInteger idx, BOOL *stop) {
        [routesDictionnary setObject:route forKey:route.id];
    }];
    
    NSMutableDictionary* stopsDictionnary = [[NSMutableDictionary alloc] init];
    [self.staticDataManager.stops enumerateObjectsUsingBlock:^(Stop* stopEntity, NSUInteger idx, BOOL *stop) {
        [stopsDictionnary setObject:stopEntity forKey:stopEntity.id];
    }];
    
    [routeStops enumerateObjectsUsingBlock:^(RouteStop* routeStop, NSUInteger idx, BOOL *stop) {
        Route* route = [routesDictionnary objectForKey:routeStop.routeId];
        Stop* stopEntity = [stopsDictionnary objectForKey:routeStop.stopId];
        NSString* direction = routeStop.directionId;
        NSNumber* sequence = routeStop.stopSequence;
        [route addStop:stopEntity forSequence:sequence forDirection:direction];
    }];
        
    //Retour
    return;
}

@end
