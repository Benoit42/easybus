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
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"
#import "RoutesStopsCsvReader.h"

@implementation StaticDataLoader
objection_register_singleton(StaticDataLoader)

objection_requires(@"managedObjectContext", @"routesCsvReader", @"routesStopsCsvReader", @"stopsCsvReader")
@synthesize  managedObjectContext, routesCsvReader, routesStopsCsvReader, stopsCsvReader;

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
//Load all data
- (void) loadData {
    //load data
    [self loadRoutes];
    [self loadStops];
    [self loadRouteStops];
    
    //save data
    NSError* error = nil;
    if (![self.managedObjectContext save:&error]) {
        //Log
        NSLog(@"Database error while saving - %@ %@", [error description], [error debugDescription]);
    }
}

//Clean and load routes
- (void) loadRoutes {
    NSManagedObjectModel *managedObjectModel = [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest *request = [managedObjectModel fetchRequestTemplateForName:@"fetchAllRoutes"];

    NSError *error = nil;
    NSArray *routes = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (routes == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    
    for (NSManagedObject* route in routes) {
        [self.managedObjectContext deleteObject:route];
    }

    [self.routesCsvReader loadData];
}

//Clean and load stops
- (void) loadStops {
    NSManagedObjectModel *managedObjectModel = [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest *request = [managedObjectModel fetchRequestTemplateForName:@"fetchAllStops"];
    
    NSError *error = nil;
    NSArray *stops = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (stops == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    
    for (NSManagedObject* stop in stops) {
        [self.managedObjectContext deleteObject:stop];
    }

    [self.stopsCsvReader loadData];
}

//Load route-stops
- (void) loadRouteStops {
    NSManagedObjectModel *managedObjectModel = [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest *request = [managedObjectModel fetchRequestTemplateForName:@"fetchAllStops"];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (result == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    
    [self.routesStopsCsvReader loadData];
}

@end
