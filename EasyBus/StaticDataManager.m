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

@implementation StaticDataManager
objection_register_singleton(StaticDataManager)

objection_requires(@"managedObjectContext", @"routesCsvReader", @"routesStopsCsvReader", @"stopsCsvReader")
@synthesize managedObjectContext, routesCsvReader, routesStopsCsvReader, stopsCsvReader;

#pragma mark init method
//- (id)init {
//    if ( self = [super init] ) {
//        //Préconditions
//        NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
//        NSAssert(self.routesCsvReader != nil, @"routesCsvReader should not be nil");
//        NSAssert(self.routesStopsCsvReader != nil, @"routesStopsCsvReader should not be nil");
//        NSAssert(self.stopsCsvReader != nil, @"stopsCsvReader should not be nil");
//    }
//    
//    return self;
//}

#pragma mark file loading method
- (void) reloadDatabase {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    //Delete all routes
    NSError * error = nil;
    NSArray * routes = [self routes];
    for (NSManagedObject * route in routes) {
        [self.managedObjectContext deleteObject:route];
    }
    
    //Delete all stops
    error = nil;
    NSArray * stops = [self stops];
    for (NSManagedObject * stop in stops) {
        [[self managedObjectContext] deleteObject:stop];
    }

    //load data
    [self.routesCsvReader loadData];
    [self.stopsCsvReader loadData];
    [self.routesStopsCsvReader loadData];
}

#pragma mark Business methods
- (NSArray*) routes {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    NSManagedObjectModel *managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *request = [managedObjectModel fetchRequestTemplateForName:@"fetchAllRoutes"];

    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
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
    if (mutableFetchResults == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
        return nil;
    }
    else if ([mutableFetchResults count] == 0) {
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
    if (mutableFetchResults == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
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
    if (mutableFetchResults == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
        return nil;
    }
    else if ([mutableFetchResults count] == 0) {
        return nil;
    }
    else {
        //Should not be more than 1
        return [mutableFetchResults objectAtIndex:0];
    }
    return nil;
}

// Return the stops for a route and a direction
//TODO : optimiser ces accès
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

- (UIImage*) pictoForRouteId:(NSString*)routeId {
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Pictogrammes_100\\%i", [routeId intValue]] ofType:@"png"]];
}

@end
