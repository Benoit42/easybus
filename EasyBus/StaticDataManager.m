//
//  StaticDataManager.m
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "StaticDataManager.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"
#import "RoutesStopsCsvReader.h"
#import "FavoritesManager.h"
#import <CoreData/CoreData.h>

@interface StaticDataManager()

@property(nonatomic) RoutesCsvReader* _routesCsvReader;
@property(nonatomic) RoutesStopsCsvReader* _routesStopsCsvReader;
@property(nonatomic) StopsCsvReader* _stopsCsvReader;

@end

@implementation StaticDataManager

@synthesize _routesCsvReader, _routesStopsCsvReader, _stopsCsvReader;
@synthesize managedObjectModel, managedObjectContext;

#pragma mark init method
- (id)initWithContext:(NSManagedObjectContext*)context andModel:(NSManagedObjectModel*)model {
    if ( self = [super init] ) {
        //initialisation des membres
        self.managedObjectContext = context;
        self.managedObjectModel = [[context persistentStoreCoordinator] managedObjectModel];
        _routesCsvReader = [[RoutesCsvReader alloc] initWithContext:self.managedObjectContext];
        _stopsCsvReader = [[StopsCsvReader alloc] initWithContext:self.managedObjectContext];
        _routesStopsCsvReader = [[RoutesStopsCsvReader alloc] initWithContext:self.managedObjectContext];
    }
    
    if ([[self routes] count] == 0) {
        [self reloadDatabase];
    }

    return self;
}

#pragma mark file loading method
- (void) reloadDatabase {
    //Delete all routes
    NSError * error = nil;
    NSArray * routes = [self routes];
    for (NSManagedObject * route in routes) {
        [[self managedObjectContext] deleteObject:route];
    }
    
    //Delete all stops
    error = nil;
    NSArray * stops = [self stops];
    for (NSManagedObject * stop in stops) {
        [[self managedObjectContext] deleteObject:stop];
    }

    //load data
    [_routesCsvReader loadData];
    [_stopsCsvReader loadData];
    [_routesStopsCsvReader loadData];
    
    //save data
    error = nil;
    if (![[self managedObjectContext] save:&error]) {
        //Log
        NSLog(@"Database error while saving - %@ %@", [error description], [error debugDescription]);
    }

}

#pragma mark Business methods
- (NSArray*) routes {
    NSFetchRequest *request = [[self managedObjectModel] fetchRequestTemplateForName:@"fetchAllRoutes"];

    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
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
    NSFetchRequest *request = [[self managedObjectModel] fetchRequestFromTemplateWithName:@"fetchRouteWithId"
                                                                    substitutionVariables:@{@"id" : routeId}];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
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
    NSFetchRequest *request = [[self managedObjectModel] fetchRequestTemplateForName:@"fetchAllStops"];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    
    return mutableFetchResults;
}

- (Stop*) stopForId:(NSString*)stopId {
    NSFetchRequest *request = [[self managedObjectModel] fetchRequestFromTemplateWithName:@"fetchStopWithId"
                      substitutionVariables:@{@"id" : stopId}];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
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

@end
