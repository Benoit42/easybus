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
@property (nonatomic, strong) NSMutableDictionary* routesTerminusDictionary;

@end

@implementation TripsCsvReader
objection_register_singleton(TripsCsvReader)

@synthesize trips;

- (void)loadData:(NSURL*)url {
    //Chargement des horaires
    NSLog(@"Chargement des trajets");
    
    //Allocation du dictionnaire
    self.trips = [[NSMutableArray alloc] initWithCapacity:25000U];
    self.routesTerminusDictionary = [[NSMutableDictionary alloc] init];
    
    //parsing du fichier
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
    if (lineNumber > 1 && self.row.count == 4) {
        // Create and configure a new instance of the Trip entity.
        Trip* trip = [[Trip alloc] init];
        trip.id = self.row[0];
        trip.routeId = self.row[1];
        trip.directionId = self.row[3];
        
        [trips addObject:trip];
        
        //Store route terminus label
        NSMutableDictionary* directionsForRoute = self.routesTerminusDictionary[trip.routeId];
        if (!directionsForRoute) {
            directionsForRoute = [[NSMutableDictionary alloc] init];
            [self.routesTerminusDictionary setObject:directionsForRoute forKey:trip.routeId];
        }
        NSMutableDictionary* terminusLabelsForDirection = directionsForRoute[trip.directionId];
        if (!terminusLabelsForDirection) {
            terminusLabelsForDirection = [[NSMutableDictionary alloc] init];
            [directionsForRoute setObject:terminusLabelsForDirection forKey:trip.directionId];
            
        }
        NSString* terminusLabel = self.row[2];
        NSNumber* numberOfOccurencesForLabel = terminusLabelsForDirection[terminusLabel];
        if (!numberOfOccurencesForLabel) {
            [terminusLabelsForDirection setObject:[NSNumber numberWithInt:0] forKey:terminusLabel];
        }
        int nbOcc = [terminusLabelsForDirection[terminusLabel] integerValue];
        nbOcc++;
        terminusLabelsForDirection[terminusLabel] = [NSNumber numberWithInt:nbOcc];
    }
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    if (fieldIndex == 0 || fieldIndex == 2 || fieldIndex == 3 || fieldIndex == 4) {
        [self.row addObject:field];
    }
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    //Process routesTerminusDictionary to get route terminus
    [self.routesTerminusDictionary enumerateKeysAndObjectsUsingBlock:^(NSString* routeId, NSMutableDictionary* directionsForRoute, BOOL *stop) {
        [directionsForRoute enumerateKeysAndObjectsUsingBlock:^(NSString* directionId, NSMutableDictionary* terminusLabelsForDirection, BOOL *stop) {
            __block NSNumber* maxOcc = nil;
            __block NSString* maxLabel = nil;
            [terminusLabelsForDirection enumerateKeysAndObjectsUsingBlock:^(NSString* currentLabel, NSNumber* nbOcc, BOOL *stop) {
                if (!maxOcc) {
                    maxOcc = nbOcc;
                    maxLabel = currentLabel;
                }
                else {
                    if ([nbOcc compare:maxOcc] ==  NSOrderedDescending) {
                        maxOcc = nbOcc;
                        maxLabel = currentLabel;
                    }
                }
            }];
            [terminusLabelsForDirection removeAllObjects];
            terminusLabelsForDirection[maxLabel] = maxOcc;
        }];
    }];
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"TripsCsvReader parser failed with error: %@ %@", [error localizedDescription], [error userInfo]);
}

- (NSString*)terminusLabelForRouteId:(NSString*)routeId andDirectionId:(NSString*)directionId {
    return [self.routesTerminusDictionary[routeId][directionId] allKeys][0];
}

- (void)cleanUp {
    self.trips = nil;
    self.routesTerminusDictionary = nil;
}

@end
