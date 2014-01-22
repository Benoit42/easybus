//
//  StaticDataManager.m
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "StaticDataManager.h"
#import "FavoritesManager.h"
#import "Route+RouteWithAdditions.h"
#import "FeedInfo.h"

@implementation StaticDataManager
objection_register_singleton(StaticDataManager)

objection_requires(@"managedObjectContext")
@synthesize managedObjectContext;

#pragma mark Business methods
- (BOOL)isDataLoaded {
    BOOL feedInfoOk = [self feedInfo] != nil;
    BOOL terminusOk = [self terminusLabelIsOk];
    return feedInfoOk && terminusOk;
}

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
    NSOrderedSet* stops = ([direction isEqual: @"0"])?[route stopsDirectionZero]:[route stopsDirectionOne];
    return [stops array];
}

- (NSArray*) nearStopsFrom:(CLLocation*)location quantity:(NSInteger)quantity {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    NSAssert(location != nil, @"location should not be nil");
    NSAssert(quantity > 0, @"quantity should not be >0");
    
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

    //tri
    NSArray *sortedStops = [mutableFetchResults sortedArrayUsingComparator:^NSComparisonResult(Stop* a, Stop* b) {
        CLLocationDistance distanceA = [a.location distanceFromLocation:location];
        CLLocationDistance distanceB = [b.location distanceFromLocation:location];
        return distanceA > distanceB;
    }];
    
    return [sortedStops subarrayWithRange:NSMakeRange(0, MIN(quantity, sortedStops.count))];
}

- (FeedInfo*) feedInfo {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    NSManagedObjectModel *managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *request = [managedObjectModel fetchRequestTemplateForName:@"fetchFeedInfo"];
    
    NSError *error = nil;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
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

//Test pour déclencher le chargement des données GTFS corrigeant le bugs des terminus
- (BOOL)terminusLabelIsOk {
    Route* route200 = [self routeForId:@"0200"];
    BOOL route200Ok = [route200.fromName isEqualToString:@"Rennes Lycée Assomption"];
    return route200Ok;
}

@end
