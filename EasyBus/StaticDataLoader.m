//
//  StaticDataManager.m
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CoreData/CoreData.h>
#import "StaticDataLoader.h"
#import "StaticDataManager.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"
#import "RouteStop.h"
#import "Route+RouteWithAdditions.h"

NSString *const dataLoadingStarted = @"dataLoadingStarted";
NSString *const dataLoadingProgress = @"dataLoadingProgress";
NSString *const dataLoadingFinished = @"dataLoadingFinished";
NSString *const dataLoadingFailed = @"dataLoadingFailed";

@interface StaticDataLoader()

@property (nonatomic) FeedInfoTmp* feedInfo;

@end

@implementation StaticDataLoader
objection_register_singleton(StaticDataLoader)

objection_requires(@"managedObjectContext", @"staticDataManager", @"routesCsvReader", @"stopsCsvReader", @"tripsCsvReader", @"stopTimesCsvReader", @"routesStopsCsvReader", @"feedInfoCsvReader", @"gtfsDownloadManager")

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
    //Pré-conditions
    NSParameterAssert(self.feedInfo != nil);
    NSParameterAssert(self.managedObjectContext != nil);
    NSParameterAssert(self.staticDataManager != nil);
    NSParameterAssert(self.routesCsvReader != nil);
    NSParameterAssert(self.stopsCsvReader != nil);
    NSParameterAssert(self.tripsCsvReader != nil);
    NSParameterAssert(self.stopTimesCsvReader != nil);
    NSParameterAssert(self.feedInfoCsvReader != nil);
    
    //Log
    NSLog(@"Démarrage du chargement des données web");
    
    //Download GTFS data from Keolis
    [[NSNotificationCenter defaultCenter] postNotificationName:dataLoadingStarted object:self];
    
    //Download update
    [self.gtfsDownloadManager downloadGtfsData:self.feedInfo.url
        withSuccessBlock:^(NSURL *outputPath) {
            //load data into database
            NSURL* feedInfosUrl = [NSURL URLWithString:@"feed_info.txt" relativeToURL:outputPath];
            [self.feedInfoCsvReader loadData:feedInfosUrl];
            NSURL* routesUrl = [NSURL URLWithString:@"routes.txt" relativeToURL:outputPath];
            [self.routesCsvReader loadData:routesUrl];
            NSURL* additionnalsRoutesUrl = [NSURL URLWithString:@"routes_additionals.txt" relativeToURL:outputPath];
            [self.routesCsvReader loadData:additionnalsRoutesUrl];
            NSURL* stopsUrl = [NSURL URLWithString:@"stops.txt" relativeToURL:outputPath];
            [self.stopsCsvReader loadData:stopsUrl];
            NSURL* tripsUrl = [NSURL URLWithString:@"trips.txt" relativeToURL:outputPath];
            [self.tripsCsvReader loadData:tripsUrl];
            NSURL* stopTimesUrl = [NSURL URLWithString:@"stop_times.txt" relativeToURL:outputPath];
            [self.stopTimesCsvReader loadData:stopTimesUrl];
            [self matchTrips:self.tripsCsvReader.trips andStops:self.stopTimesCsvReader.stops];
            
            //Set routes terminus
            [self setRoutesTerminus];
            
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
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
    NSParameterAssert(self.staticDataManager != nil);
    NSParameterAssert(self.routesCsvReader != nil);
    NSParameterAssert(self.stopsCsvReader != nil);
    NSParameterAssert(self.routesStopsCsvReader != nil);
    
    //Log
    NSLog(@"Démarrage du chargement des données locales");
    
    //load data
    NSURL* feedInfosUrl = [NSURL URLWithString:@"feed_info.txt" relativeToURL:directory];
    [self.feedInfoCsvReader loadData:feedInfosUrl];
    NSURL* tripsUrl = [NSURL URLWithString:@"trips.txt" relativeToURL:directory];
    [self.tripsCsvReader loadData:tripsUrl];
    NSURL* routesUrl = [NSURL URLWithString:@"routes.txt" relativeToURL:directory];
    [self.routesCsvReader loadData:routesUrl];
    NSURL* additionnalsRoutesUrl = [NSURL URLWithString:@"routes_additionals.txt" relativeToURL:directory];
    [self.routesCsvReader loadData:additionnalsRoutesUrl];
    NSURL* stopsUrl = [NSURL URLWithString:@"stops.txt" relativeToURL:directory];
    [self.stopsCsvReader loadData:stopsUrl];
    NSURL* routesStops = [NSURL URLWithString:@"routes_stops.txt" relativeToURL:directory];
    [self.routesStopsCsvReader loadData:routesStops];
    [self matchRoutesAndStops:self.routesStopsCsvReader.routesStops];
    
    //Set routes terminus
    [self setRoutesTerminus];
    
    //clean-up
    [self.tripsCsvReader cleanUp];
    [self.routesCsvReader cleanUp];
    [self.stopsCsvReader cleanUp];
    [self.routesStopsCsvReader cleanUp];
    
    //Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:dataLoadingFinished object:self];
    
    //Log
    NSLog(@"Fin du chargement des données locales");
}

// Association route/stop
- (void) setRoutesTerminus {
    [self.staticDataManager.routes enumerateObjectsUsingBlock:^(Route* route, NSUInteger idx, BOOL *stop) {
        //récupération du label
        NSString* terminus0 = [self.tripsCsvReader terminusLabelForRouteId:route.id andDirectionId:@"0"];
        NSString* terminus1 = [self.tripsCsvReader terminusLabelForRouteId:route.id andDirectionId:@"1"];

        //Calcul des libellés des départs et arrivée
        //Exemple : "61 | Acigné"
        //Split sur le | et suppression de la partie gauche
        NSArray* subs0 = [terminus0 componentsSeparatedByString:@"|"];
        NSString* terminus0RightPart = ([subs0 count] > 1) ? [subs0 objectAtIndex:1] : @"Terminus inconnu";
        NSArray* subs1 = [terminus1 componentsSeparatedByString:@"|"];
        NSString* terminus1RightPart = ([subs1 count] > 1) ? [subs1 objectAtIndex:1] : @"Terminus inconnu";
        
        route.fromName = [terminus0RightPart stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        route.toName = [terminus1RightPart stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    }];
}

// Association route/stop
- (void) matchTrips:(NSArray*)trips andStops:(NSArray*)stops {
    //Pré-conditions
    NSAssert(trips != nil, @"tripsCsvReader should not be nil");
    NSAssert(stops != nil, @"stopTimesCsvReader should not be nil");
    
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
    
    //Tri des données
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
                NSNumber* sequence = [NSNumber numberWithInt:([stopTime.stopSequence integerValue] - 1)];
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
        NSNumber* sequence = [NSNumber numberWithInt:([routeStop.stopSequence integerValue] - 1)];
        [route addStop:stopEntity forSequence:sequence forDirection:direction];
    }];
        
    //Retour
    return;
}

@end
