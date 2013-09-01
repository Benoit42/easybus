//
//  StaticDataManager.m
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "StaticDataLoader.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"
#import "RoutesStopsCsvReader.h"

@interface StaticDataLoader()

@property(nonatomic) RoutesCsvReader* _routesCsvReader;
@property(nonatomic) RoutesStopsCsvReader* _routesStopsCsvReader;
@property(nonatomic) StopsCsvReader* _stopsCsvReader;

@property (nonatomic, retain, readonly) NSManagedObjectModel *_managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *_managedObjectContext;

@end

@implementation StaticDataLoader

@synthesize _routesCsvReader, _routesStopsCsvReader, _stopsCsvReader;
@synthesize _managedObjectModel, _managedObjectContext;

#pragma mark init method
- (id)initWithContext:(NSManagedObjectContext*)managedObjectContext {
    if ( self = [super init] ) {
        //initialisation des membres
        _managedObjectContext = managedObjectContext;
        _managedObjectModel = [[_managedObjectContext persistentStoreCoordinator] managedObjectModel];
    }

    return self;
}

#pragma mark file loading method
//Load all data
- (void) loadData {
    //load data
    [self loadRoutes];
    [self loadStops];
    [self loadRouteStops];
    
    //save data
    NSError* error = nil;
    if (![_managedObjectContext save:&error]) {
        //Log
        NSLog(@"Database error while saving - %@ %@", [error description], [error debugDescription]);
    }
}

//Clean and load routes
- (void) loadRoutes {
    NSFetchRequest *request = [_managedObjectModel fetchRequestTemplateForName:@"fetchAllRoutes"];

    NSError *error = nil;
    NSArray *routes = [_managedObjectContext executeFetchRequest:request error:&error];
    if (routes == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    
    for (NSManagedObject* route in routes) {
        [_managedObjectContext deleteObject:route];
    }

    [_routesCsvReader loadData];
}

//Clean and load stops
- (void) loadStops {
    NSFetchRequest *request = [_managedObjectModel fetchRequestTemplateForName:@"fetchAllStops"];
    
    NSError *error = nil;
    NSArray *stops = [_managedObjectContext executeFetchRequest:request error:&error];
    if (stops == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    
    for (NSManagedObject* stop in stops) {
        [_managedObjectContext deleteObject:stop];
    }

    [_stopsCsvReader loadData];
}

//Load route-stops
- (void) loadRouteStops {
    NSFetchRequest *request = [_managedObjectModel fetchRequestTemplateForName:@"fetchAllStops"];
    
    NSError *error = nil;
    NSArray *result = [_managedObjectContext executeFetchRequest:request error:&error];
    if (result == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    
    [_routesStopsCsvReader loadData];
}

@end
