//
//  RouteStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CHCSVParser/CHCSVParser.h>
#import "StopTimesCsvReader.h"

@interface StopTimesCsvReader() <CHCSVParserDelegate>

@property (nonatomic, strong) NSMutableArray* row;

@end

@implementation StopTimesCsvReader
objection_register_singleton(StopTimesCsvReader)

- (void)loadData:(NSURL*)url {
    //Chargement des horaires
    NSLog(@"Chargement des horaires");
    
    //Initialisation du progress
    self.progress = [NSProgress progressWithTotalUnitCount:611396]; //approx
    
    //Allocation du dictionnaire
    self.stopTimes = [[NSMutableArray alloc] initWithCapacity:600000U];
    
    //Lecture du fichier
    //Question : pourquoi est-il plus rapide de lire préalablement le fichier ?
    NSError* error;
    NSString *csvString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];

    //parsing du fichier
    self.row = [[NSMutableArray alloc] init];
    //Pourquoi ç'est plus rapide qu'avec initWithContentsOfCSVFile ???
    CHCSVParser * p = [[CHCSVParser alloc] initWithCSVString:csvString];
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
    if (lineNumber > 1 && self.row.count == 3) {
        // Create and configure a new instance of the StopTime entity.
        StopTime* stopTime = [[StopTime alloc] init];
        stopTime.tripId = self.row[0];
        stopTime.stopId= self.row[1];
        stopTime.stopSequence = [NSNumber numberWithInteger:[self.row[2] integerValue]];
        
        [self.stopTimes addObject:stopTime];
    }
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    if (fieldIndex < 3) {
        [self.row addObject:field];
    }
}

- (void) parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"StopTimesCsvReader parser failed with error: %@ %@", [error localizedDescription], [error userInfo]);
}

- (void)cleanUp {
    self.stopTimes = nil;
}

@end
