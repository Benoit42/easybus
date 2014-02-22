//
//  NSManagedObjectContext+EasyBus.m
//  EasyBus
//
//  Created by Benoît on 08/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import "NSManagedObjectContext+Network.h"

@implementation NSManagedObjectContext (Network)

#pragma mark - Model
- (NSManagedObjectModel*)managedObjectModel {
    return self.persistentStoreCoordinator.managedObjectModel;
}

#pragma mark - Manage feed info
- (FeedInfo*) feedInfo {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"fetchFeedInfo"];
    
    NSError *error = nil;
    NSArray *fetchResults = [self executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (fetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }
    
    return (fetchResults.count>0)?fetchResults[0]:nil;
}

#pragma mark - Manage routes
- (NSArray*) routes {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"fetchAllRoutes"];
    
    NSError *error = nil;
    NSArray *fetchResults = [self executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (fetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }

    return fetchResults;
}

- (NSArray*) sortedRoutes {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                    initWithKey:@"id" ascending:YES];
    NSArray* routes = [[self routes] sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return routes;
}

- (Route*) routeForId:(NSString*)routeId {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"fetchRouteWithId"
                                                             substitutionVariables:@{@"id" : routeId}];
    
    NSError *error = nil;
    NSArray *fetchResults = [self executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (fetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
        return nil;
    }
    
    return (fetchResults.count>0)?fetchResults[0]:nil;
}

#pragma mark - Manage stops
- (NSArray*) stops {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"fetchAllStops"];
    
    NSError *error = nil;
    NSArray *fetchResults = [self executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (fetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }
    
    return fetchResults;
}

- (Stop*) stopForId:(NSString*)stopId {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"fetchStopWithId"
                                                             substitutionVariables:@{@"id" : stopId}];
    
    NSError *error = nil;
    NSArray *fetchResults = [self executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (fetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }
    
    if ([fetchResults count] == 0) {
        return nil;
    }
    else {
        //Should not be more than 1
        return [fetchResults objectAtIndex:0];
    }
    return nil;
}

- (NSArray*) stopsForRoute:(Route*)route direction:(NSString*)direction {
    NSOrderedSet* stops = ([direction isEqual: @"0"])?[route stopsDirectionZero]:[route stopsDirectionOne];
    return [stops array];
}

- (NSArray*) stopsSortedByDistanceFrom:(CLLocation*)location {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"fetchAllStops"];
    
    NSError *error = nil;
    NSArray *fetchResults = [self executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (fetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }
    
    //Sort stops by distance from location
    NSArray* sortedStops = [fetchResults sortedArrayUsingComparator:^NSComparisonResult(Stop* stop1, Stop* stop2) {
        return [[NSNumber numberWithDouble:[stop1.location distanceFromLocation:location]] compare:[NSNumber numberWithDouble:[stop2.location distanceFromLocation:location]]];
    }];
    
    return sortedStops;
}

- (NSArray*) nearestStopsHavingSameNameFrom:(CLLocation*)location {
    //Récupération de tous les stops, triés par distance
    NSArray* result = [NSArray array];
    
    //Filtrage des stops ayant le même nom que le plus proche
    NSArray* stops = [self stopsSortedByDistanceFrom:location];
    if (stops.count > 0) {
        Stop* nearestStop = stops[0];
        NSPredicate* namePredicate = [NSPredicate predicateWithFormat:@"name == %@", nearestStop.name];
        result = [stops filteredArrayUsingPredicate:namePredicate];
    }
    
    //Retour
    return result;
}

@end
