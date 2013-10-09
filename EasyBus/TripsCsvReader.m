//
//  RouteStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CHCSVParser/CHCSVParser.h>
#import "TripsCsvReader.h"

@interface TripsCsvReader() <CHCSVParserDelegate>

@property (nonatomic, strong) NSMutableArray* row;

@end

@implementation TripsCsvReader
objection_register_singleton(TripsCsvReader)

@synthesize trips;

- (void)loadData {
    //Chargement des horaires
    NSLog(@"Chargement des trajets");
    
    //Allocation du dictionnaire
    self.trips = [[NSMutableArray alloc] initWithCapacity:25000U];
    
    //parsing du fichier
    //Pourquoi ça ne marche pas avec initWithContentsOfCSVFile ???
    self.row = [[NSMutableArray alloc] init];
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"trips" withExtension:@"txt"];
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
    if (lineNumber > 1 && self.row.count == 3) {
        // Create and configure a new instance of the Trip entity.
        Trip* trip = [[Trip alloc] init];
        trip.id = self.row[0];
        trip.routeId = self.row[1];
        trip.directionId = self.row[2];
        
        [trips addObject:trip];
    }
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    if (fieldIndex == 0 || fieldIndex == 2 || fieldIndex == 4) {
        [self.row addObject:field];
    }
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"TripsCsvReader parser failed with error: %@ %@", [error localizedDescription], [error userInfo]);
}

- (void)cleanUp {
    trips = nil;
}

@end
