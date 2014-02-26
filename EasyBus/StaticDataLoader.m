//
//  StaticDataLoader.m
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CoreData/CoreData.h>
#import "StaticDataLoader.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"
#import "RouteStop.h"
#import "Route+Additions.h"
#import "NSManagedObjectContext+Network.h"

NSString *const dataLoadingStarted = @"dataLoadingStarted";
NSString *const dataLoadingProgress = @"dataLoadingProgress";
NSString *const dataLoadingFinished = @"dataLoadingFinished";
NSString *const dataLoadingFailed = @"dataLoadingFailed";

@interface StaticDataLoader()

@property (nonatomic) FeedInfoTmp* feedInfo;

@end

@implementation StaticDataLoader
objection_register_singleton(StaticDataLoader)
objection_requires(@"managedObjectContext", @"routesCsvReader", @"stopsCsvReader", @"tripsCsvReader", @"terminusJsonReader", @"stopTimesCsvReader", @"routesStopsCsvReader", @"feedInfoCsvReader", @"gtfsDownloadManager")

#pragma mark - Constructeur
-(id)init {
    if ( self = [super init] ) {
        //Initialisation du progress
        self.progress = [[NSProgress alloc] init];
    }
    
    return self;
}

- (void)awakeFromObjection {
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext);
    NSParameterAssert(self.feedInfoCsvReader);
    NSParameterAssert(self.routesCsvReader);
    NSParameterAssert(self.stopsCsvReader);
    NSParameterAssert(self.tripsCsvReader);
    NSParameterAssert(self.stopTimesCsvReader);
    NSParameterAssert(self.feedInfoCsvReader);
}

#pragma mark web file loading method
-(void)checkUpdate:(NSDate*)date withSuccessBlock:(void(^)(BOOL, NSString* version))success andFailureBlock:(void(^)(NSError* error))failure {
    //Pré-conditions
    NSParameterAssert(self.gtfsDownloadManager != nil);
    
    //Get GTFS file infos
    [self.gtfsDownloadManager getGtfsDataForDate:date
                   withSuccessBlock:^(FeedInfoTmp* newFeedInfo) {
                       //Store feed infos
                       self.feedInfo = newFeedInfo;
                       
                       //Check if update needed
                       BOOL updateAvailable =  (newFeedInfo) && (newFeedInfo.url) && (([date compare:newFeedInfo.startDate] == NSOrderedDescending)|| ([date compare:newFeedInfo.endDate] == NSOrderedAscending)) ;//&& ([self.feedInfo.publishDate compare:newFeedInfo.publishDate] == NSOrderedAscending);
                       success(updateAvailable, newFeedInfo.version);
                   }
                    andFailureBlock:^(NSError *error) {
                        //End
                        failure(error);
                        
                        //Log
                        NSLog(@"Error: %@", [error debugDescription]);
                    }];
}

- (void)loadDataFromWebWithSuccessBlock:(void(^)(void))success andFailureBlock:(void(^)(NSError* error))failure {
    //Log
    NSLog(@"Démarrage du chargement des données web");
    
    //Initialisation du progress
    [self.progress setTotalUnitCount:90];

    //Download GTFS data from Keolis
    [[NSNotificationCenter defaultCenter] postNotificationName:dataLoadingStarted object:self];
    
    //Download update
    [self.gtfsDownloadManager downloadGtfsData:self.feedInfo.url
        withSuccessBlock:^(NSURL *outputPath) {
            //load data into database
            NSURL* feedInfosUrl = [NSURL URLWithString:@"feed_info.txt" relativeToURL:outputPath];
            [self.progress becomeCurrentWithPendingUnitCount:10];
            [self.feedInfoCsvReader loadData:feedInfosUrl];
            [self.progress resignCurrent];

            NSURL* routesUrl = [NSURL URLWithString:@"routes.txt" relativeToURL:outputPath];
            [self.progress becomeCurrentWithPendingUnitCount:10];
            [self.routesCsvReader loadData:routesUrl];
            [self.progress resignCurrent];

            NSURL* additionnalsRoutesUrl = [NSURL URLWithString:@"routes_additionals.txt" relativeToURL:outputPath];
            [self.progress becomeCurrentWithPendingUnitCount:10];
            [self.routesCsvReader loadData:additionnalsRoutesUrl];
            [self.progress resignCurrent];

            NSURL* stopsUrl = [NSURL URLWithString:@"stops.txt" relativeToURL:outputPath];
            [self.progress becomeCurrentWithPendingUnitCount:10];
            [self.stopsCsvReader loadData:stopsUrl];
            [self.progress resignCurrent];

            NSURL* tripsUrl = [NSURL URLWithString:@"trips.txt" relativeToURL:outputPath];
            [self.progress becomeCurrentWithPendingUnitCount:10];
            [self.tripsCsvReader loadData:tripsUrl];
            [self.progress resignCurrent];

            NSURL* stopTimesUrl = [NSURL URLWithString:@"stop_times.txt" relativeToURL:outputPath];
            [self.progress becomeCurrentWithPendingUnitCount:10];
            [self.stopTimesCsvReader loadData:stopTimesUrl];
            [self.progress resignCurrent];

            [self.progress becomeCurrentWithPendingUnitCount:10];
            NSArray* routesStops = [self matchTrips:self.tripsCsvReader.trips andStops:self.stopTimesCsvReader.stopTimes];
            [self.progress resignCurrent];
            
            [self.progress becomeCurrentWithPendingUnitCount:13];
            [self linkRoutesAndStops:routesStops];
            [self.progress resignCurrent];
            
            //Nettoyage des routes et stops inutilisés
            [self.progress becomeCurrentWithPendingUnitCount:10];
            [self cleanupData];
            [self.progress resignCurrent];
            
            //Set routes terminus
            [self.progress becomeCurrentWithPendingUnitCount:10];
            [self setRoutesTerminus:self.tripsCsvReader.terminus];
            [self.progress resignCurrent];
            
            //clean-up
            [self.feedInfoCsvReader cleanUp];
            [self.routesCsvReader cleanUp];
            [self.stopsCsvReader cleanUp];
            [self.tripsCsvReader cleanUp];
            [self.stopTimesCsvReader cleanUp];
            
            //Response and notification
            success();
            [[NSNotificationCenter defaultCenter] postNotificationName:dataLoadingFinished object:self];
            
            //Log
            NSLog(@"Fin du chargement des données web");

            //CleanUp
            [self.gtfsDownloadManager cleanUp];
        }
        andFailureBlock:^(NSError *error) {
            //Response and notification
            failure(error);
            [[NSNotificationCenter defaultCenter] postNotificationName:dataLoadingFailed object:self];
            
            //Log
            NSLog(@"Erreur lors du chargement des données web");
        
    }];
}

#pragma mark local file loading method
- (void)loadDataFromLocalFiles:(NSURL*)directory {
    //Log
    NSLog(@"Démarrage du chargement des données locales");
    
    //Initialisation du progress
    [self.progress setTotalUnitCount:101];
    
    //load data
    NSURL* feedInfosUrl = [NSURL URLWithString:@"feed_info.txt" relativeToURL:directory];
    [self.progress becomeCurrentWithPendingUnitCount:1];
    [self.feedInfoCsvReader loadData:feedInfosUrl];
    [self.progress resignCurrent];
    
    NSURL* routesUrl = [NSURL URLWithString:@"routes.txt" relativeToURL:directory];
    [self.progress becomeCurrentWithPendingUnitCount:5];
    [self.routesCsvReader loadData:routesUrl];
    [self.progress resignCurrent];
    
    NSURL* additionnalsRoutesUrl = [NSURL URLWithString:@"routes_additionals.txt" relativeToURL:directory];
    [self.progress becomeCurrentWithPendingUnitCount:3];
    [self.routesCsvReader loadData:additionnalsRoutesUrl];
    [self.progress resignCurrent];
    
    NSURL* stopsUrl = [NSURL URLWithString:@"stops.txt" relativeToURL:directory];
    [self.progress becomeCurrentWithPendingUnitCount:65];
    [self.stopsCsvReader loadData:stopsUrl];
    [self.progress resignCurrent];
    
    NSURL* routesStops = [NSURL URLWithString:@"routes_stops.txt" relativeToURL:directory];
    [self.progress becomeCurrentWithPendingUnitCount:3];
    [self.routesStopsCsvReader loadData:routesStops];
    [self.progress resignCurrent];
    
    [self.progress becomeCurrentWithPendingUnitCount:13];
    [self linkRoutesAndStops:self.routesStopsCsvReader.routesStops];
    [self.progress resignCurrent];
    
    //Nettoyage des routes et stops inutilisés
    [self.progress becomeCurrentWithPendingUnitCount:1];
    [self cleanupData];
    [self.progress resignCurrent];
    
    //Set routes terminus
    NSURL* terminusUrl = [NSURL URLWithString:@"terminus.json" relativeToURL:directory];
    [self.progress becomeCurrentWithPendingUnitCount:1];
    [self.terminusJsonReader loadData:terminusUrl];
    [self setRoutesTerminus:self.terminusJsonReader.terminus];
    [self.terminusJsonReader cleanUp];
    [self.progress resignCurrent];
    
    //clean-up
    [self.routesCsvReader cleanUp];
    [self.stopsCsvReader cleanUp];
    [self.routesStopsCsvReader cleanUp];
    [self.terminusJsonReader cleanUp];
    
    //Sauvegarde
    NSError* error;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error while saving data in main context : %@", error.description);
    }

    //Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:dataLoadingFinished object:self];
    
    //Log
    NSLog(@"Fin du chargement des données locales");
}

// Calcul des libellés de terminus
- (void) setRoutesTerminus:(NSDictionary*)terminus {
    //Log
    NSLog(@"Calcul des libellés de terminus");
    
    //Initialisation du progress
    NSProgress* progress = [NSProgress progressWithTotalUnitCount:self.managedObjectContext.routes];
    
    [self.managedObjectContext.routes enumerateObjectsUsingBlock:^(Route* route, NSUInteger idx, BOOL *stop) {
        //Récupération du label
        route.fromName = terminus[route.id][@"0"];
        route.toName = terminus[route.id][@"1"];
        
        //Progress
        [progress setCompletedUnitCount:idx];
    }];
}

// Association route/stop
- (NSArray*) matchTrips:(NSArray*)trips andStops:(NSArray*)stopTimes {
    //Pré-conditions
    NSParameterAssert(trips != nil);
    NSParameterAssert(stopTimes != nil);
    
    //Log
    NSLog(@"Association trajet/arrêts");
    
    //Pre-fetching
    NSMutableDictionary* routesDictionnary = [[NSMutableDictionary alloc] init];
    [self.managedObjectContext.routes enumerateObjectsUsingBlock:^(Route* route, NSUInteger idx, BOOL *stop) {
        [routesDictionnary setObject:route forKey:route.id];
    }];
    
    NSMutableDictionary* stopsDictionnary = [[NSMutableDictionary alloc] init];
    [self.managedObjectContext.stops enumerateObjectsUsingBlock:^(Stop* stopEntity, NSUInteger idx, BOOL *stop) {
        [stopsDictionnary setObject:stopEntity forKey:stopEntity.id];
    }];
    
    //Tri des données
    trips = [trips sortedArrayUsingComparator:^NSComparisonResult(TripItem* trip1, TripItem* trip2) {
        return [trip1.id compare:trip2.id];
    }];
    stopTimes = [stopTimes sortedArrayUsingComparator:^NSComparisonResult(StopTime* st1, StopTime* st2) {
        NSComparisonResult compareTrips = [st1.tripId compare:st2.tripId];
        if (compareTrips == NSOrderedSame) {
            return [st1.stopSequence compare:st2.stopSequence];
        }
        else {
            return compareTrips;
        }
    }];
    
    //Initialisation du progress
    NSProgress* progress = [NSProgress progressWithTotalUnitCount:trips.count];
    
    //Matching route/stop
    NSMutableSet* routesStops = [[NSMutableSet alloc] init];
    int i=0, j=0;
    while (i < trips.count) {
        TripItem* trip = trips[i];
        while (j < stopTimes.count) {
            StopTime* stopTime = stopTimes[j];
            if ([trip.id compare:stopTime.tripId] == NSOrderedAscending) {
                break;
            }
            else if ([trip.id compare:stopTime.tripId] == NSOrderedDescending) {
                continue;
            }
            else {
                //Les tripId matchent
                RouteStop* routeStop  = [[RouteStop alloc] init];
                routeStop.routeId = trip.routeId;
                routeStop.stopId = stopTime.stopId;
                routeStop.directionId = trip.directionId;
                routeStop.stopSequence = stopTime.stopSequence;
                [routesStops addObject:routeStop];
                
                //Incrément de boucle
                j++;
            }
        }
        
        //Incrément de boucle
        i++;
        
        //Progress
        [progress setCompletedUnitCount:i];
    }
    
    //Retour
    return [routesStops allObjects];
}

- (void) linkRoutesAndStops:(NSArray*)routeStops {
    //Pré-conditions
    NSParameterAssert(routeStops != nil);
    
    //Log
    NSLog(@"Association route/arrêts");
    
    //Pre-fetching
    NSMutableDictionary* routesDictionnary = [[NSMutableDictionary alloc] init];
    [self.managedObjectContext.routes enumerateObjectsUsingBlock:^(Route* route, NSUInteger idx, BOOL *stop) {
        [routesDictionnary setObject:route forKey:route.id];
        [route removeStopsDirectionZero:[route stopsDirectionZero]];
        [route removeStopsDirectionOne:[route stopsDirectionOne]];
    }];
    
    NSMutableDictionary* stopsDictionnary = [[NSMutableDictionary alloc] init];
    [self.managedObjectContext.stops enumerateObjectsUsingBlock:^(Stop* stopEntity, NSUInteger idx, BOOL *stop) {
        [stopsDictionnary setObject:stopEntity forKey:stopEntity.id];
    }];
    
    //Initialisation du progress
    NSProgress* progress = [NSProgress progressWithTotalUnitCount:routeStops.count];
    
    //Tri des données
    routeStops = [routeStops sortedArrayUsingComparator:^NSComparisonResult(RouteStop* rs1, RouteStop* rs2) {
        NSComparisonResult compareRoutes = [rs1.routeId compare:rs2.routeId];
        if (compareRoutes == NSOrderedSame) {
            NSComparisonResult compareDirection = [rs1.directionId compare:rs2.directionId];
            if (compareDirection == NSOrderedSame) {
                return [rs1.stopSequence compare:rs2.stopSequence];
            }
            else {
                return compareDirection;
            }
        }
        else {
            return compareRoutes;
        }
    }];
    
    //Matching route/stop
    [routeStops enumerateObjectsUsingBlock:^(RouteStop* routeStop, NSUInteger idx, BOOL *stop) {
        Route* route = [routesDictionnary objectForKey:routeStop.routeId];
        Stop* stopEntity = [stopsDictionnary objectForKey:routeStop.stopId];
        NSString* direction = routeStop.directionId;
        if (route && stopEntity && direction) {
            [route addStop:stopEntity forDirection:direction];
        }
        else {
            NSLog(@"Données incohérentes : %@-%@-%@ ", route.id, stopEntity.id, direction);
        }

        //Progress
        [progress setCompletedUnitCount:idx];
    }];
    
    //Retour
    return;
}

- (void) cleanupData {
    //Log
    NSLog(@"Nettoyage des lignes et arrêts inutilisés");
    
    //Initialisation du progress
    NSArray* stops = [self.managedObjectContext stops];
    NSArray* routes = [self.managedObjectContext routes];
    NSProgress* progress = [NSProgress progressWithTotalUnitCount:stops.count + routes.count];
    
    //Clean-up unused stops
    NSUInteger beforeCleanUp = [[self.managedObjectContext stops] count];
    [stops enumerateObjectsUsingBlock:^(Stop* stopEntity, NSUInteger idx, BOOL *stop) {
        if ([[stopEntity routesDirectionZero] count] == 0 && [[stopEntity routesDirectionOne] count] == 0) {
            [stopEntity.managedObjectContext deleteObject:stopEntity];
        }
        
        //Progress
        progress.completedUnitCount++;
    }];
    
    NSUInteger afterCleanUp = [[self.managedObjectContext stops] count];
    NSLog(@"Nettoyage des arrêts inutilisés : %i arrêts supprimés", beforeCleanUp - afterCleanUp);
    
    //Clean-up unused stops
    beforeCleanUp = [[self.managedObjectContext routes] count];
    [routes enumerateObjectsUsingBlock:^(Route* route, NSUInteger idx, BOOL *stop) {
        if ([[route stopsDirectionZero] count] == 0 && [[route stopsDirectionOne] count] == 0) {
            [route.managedObjectContext deleteObject:route];
        }

        
        //Progress
        progress.completedUnitCount++;
    }];
    afterCleanUp = [[self.managedObjectContext routes] count];
    NSLog(@"Nettoyage des routes inutilisées : %i routes supprimées", beforeCleanUp - afterCleanUp);
    
    //Retour
    return;
}
    
@end
