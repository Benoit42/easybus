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

- (void)loadData:(NSURL*)url {
    //Chargement des horaires
    NSLog(@"Chargement des trajets");
    
    //Initialisation du progress
    self.progress = [NSProgress progressWithTotalUnitCount:23678]; //approx
    
    //Allocation du dictionnaire
    self.trips = [[NSMutableArray alloc] initWithCapacity:25000U];
    self.terminus = [[NSMutableDictionary alloc] init];
    
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
    [self.progress setCompletedUnitCount:lineNumber];
    if (lineNumber > 1 && self.row.count == 4) {
        // Create and configure a new instance of the Trip entity.
        Trip* trip = [[Trip alloc] init];
        trip.id = self.row[0];
        trip.routeId = self.row[1];
        trip.directionId = self.row[3];
        
        [self.trips addObject:trip];
        
        //Store route terminus label
        NSMutableDictionary* directionsForRoute = self.terminus[trip.routeId];
        if (!directionsForRoute) {
            directionsForRoute = [[NSMutableDictionary alloc] init];
            [self.terminus setObject:directionsForRoute forKey:trip.routeId];
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
    //Get most frequent terminus
    [self.terminus enumerateKeysAndObjectsUsingBlock:^(NSString* routeId, NSMutableDictionary* directionsForRoute, BOOL *stop) {
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

    //Remove first part of label
    [self.terminus enumerateKeysAndObjectsUsingBlock:^(NSString* routeId, NSMutableDictionary* directionsForRoute, BOOL *stop) {
        [directionsForRoute enumerateKeysAndObjectsUsingBlock:^(NSString* directionId, NSMutableDictionary* terminusLabelsForDirection, BOOL *stop) {
            //Nettoyage des libellés
            //Exemple : "61 | Acigné"
            //Split sur le | et suppression de la partie gauche
            NSString* label = [terminusLabelsForDirection allKeys][0];
            NSArray* subs = [label componentsSeparatedByString:@"|"];
            NSString* cleanLabel = ([subs count] > 1) ? [subs objectAtIndex:1]  : [subs objectAtIndex:0];
            directionsForRoute[directionId] = [cleanLabel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }];
    }];
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"TripsCsvReader parser failed with error: %@ %@", [error localizedDescription], [error userInfo]);
}

- (NSString*)terminusLabelForRouteId:(NSString*)routeId andDirectionId:(NSString*)directionId {
    return self.terminus[routeId][directionId];
}

- (void)cleanUp {
    self.trips = nil;
    self.terminus = nil;
}

@end
