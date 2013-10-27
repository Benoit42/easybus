//
//  RoutesStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CoreData/CoreData.h>
#import <CHCSVParser/CHCSVParser.h>
#import "StopsCsvReader.h"

@interface StopsCsvReader() <CHCSVParserDelegate>

@property (nonatomic, strong) NSMutableArray* row;

@end

@implementation StopsCsvReader
objection_register_singleton(StopsCsvReader)

objection_requires(@"managedObjectContext")
@synthesize managedObjectContext;

- (void)loadData:(NSURL*)url {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    //Chargement des stops
    NSLog(@"Chargement des stops");
    
    //parsing du fichier
    //Pourquoi ça ne marche pas avec initWithContentsOfCSVFile ???
    self.row = [[NSMutableArray alloc] init];
    CHCSVParser * p = [[CHCSVParser alloc] initWithContentsOfCSVFile:[url path]];
    p.sanitizesFields = YES;
    [p setDelegate:self];
    [p parse];
}

#pragma mark CHCSVParserDelegate methods
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    [self.row removeAllObjects];
}

- (void) parser:(CHCSVParser *)parser didEndLine:(NSUInteger)lineNumber {
    if (lineNumber > 1 && self.row.count == 6) {
        // Create and configure a new instance of the Stop entity.
        Stop* stop = (Stop*)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
        stop.id = self.row[0];
        stop.code = self.row[1];
        stop.name = self.row[2];
        stop.desc = self.row[3];
        stop.latitude = self.row[4];
        stop.longitude = self.row[5];
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
    //nothing
}

@end
