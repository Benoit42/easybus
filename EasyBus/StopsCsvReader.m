//
//  RoutesStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <CHCSVParser/CHCSVParser.h>
#import "StopsCsvReader.h"

@interface StopsCsvReader() <CHCSVParserDelegate>

@property (nonatomic, strong) NSDictionary* currentStops;
@property (nonatomic, strong) NSMutableArray* row;

@end

@implementation StopsCsvReader
objection_register_singleton(StopsCsvReader)
objection_requires(@"managedObjectContext")

- (void)loadData:(NSURL*)url {
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
    
    //Initialisation du progress
    self.progress = [NSProgress progressWithTotalUnitCount:1410]; //approx
    
    //Chargement des stops
    NSLog(@"Chargement des stops");
    self.currentStops = [self stops];

    //parsing du fichier
    self.row = [[NSMutableArray alloc] init];
    CHCSVParser * p = [[CHCSVParser alloc] initWithContentsOfCSVFile:[url path]];
    p.sanitizesFields = YES;
    [p setDelegate:self];
    [p parse];

    //Clean-up
    self.currentStops = nil;
    self.row = nil;
}

#pragma mark CHCSVParserDelegate methods
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    [self.row removeAllObjects];
}

- (void) parser:(CHCSVParser *)parser didEndLine:(NSUInteger)lineNumber {
    [self.progress setCompletedUnitCount:lineNumber];
    if (lineNumber > 1 && self.row.count == 6) {
        //Get route in database
        Stop* stop = [self.currentStops objectForKey:self.row[0]];
        if (stop == nil) {
            // Create Stop entity if needed
            stop = (Stop*)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
        }
        
        //Configure Stop entity
        stop.id = self.row[0];
        stop.code = self.row[1];
        stop.name = self.row[2];
        stop.desc = self.row[3];
        stop.location = [[CLLocation alloc] initWithLatitude:[self.row[4] doubleValue] longitude:[self.row[5] doubleValue]];
    }
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    if (fieldIndex < 6) {
        [self.row addObject:field];
    }
}

- (void) parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"StopsCsvReader parser failed with error: %@ %@", [error localizedDescription], [error userInfo]);
}

- (void)cleanUp {
    //Nothing
}

- (NSDictionary*) stops {
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
    
    NSManagedObjectModel *managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *request = [managedObjectModel fetchRequestTemplateForName:@"fetchAllStops"];
    
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
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [fetchResults enumerateObjectsUsingBlock:^(Stop* stopEntity, NSUInteger idx, BOOL *stop) {
        [dict setObject:stopEntity forKey:stopEntity.id];
    }];
    
    return dict;
}
@end
