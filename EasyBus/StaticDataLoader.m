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

@implementation StaticDataLoader
objection_register_singleton(StaticDataLoader)

objection_requires(@"managedObjectContext", @"routesCsvReader", @"stopsCsvReader")
@synthesize  managedObjectContext, routesCsvReader, stopsCsvReader;

#pragma mark file loading method
//Load all data
- (void) loadData {
    //load data
    [self loadRoutes];
    [self loadStops];
    
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
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (routes == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
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
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (stops == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }
    
    for (NSManagedObject* stop in stops) {
        [self.managedObjectContext deleteObject:stop];
    }

    [self.stopsCsvReader loadData];
}

@end
