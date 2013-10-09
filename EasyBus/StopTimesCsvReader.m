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

@synthesize stops;

- (void)loadData {
    //Chargement des horaires
    NSLog(@"Chargement des horaires");
    
    //Allocation du dictionnaire
    self.stops = [[NSMutableArray alloc] initWithCapacity:600000U];
    
    //Lecture du fichier
    //Question : pourquoi est-il plus rapide de lire préalablement le fichier ?
    NSError* error;
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"stop_times" withExtension:@"txt"];
    NSString *csvString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];

    //parsing du fichier
    self.row = [[NSMutableArray alloc] init];
    CHCSVParser * p = [[CHCSVParser alloc] initWithCSVString:csvString];
    p.sanitizesFields = YES;
    [p setDelegate:self];
    [p parse];
    
    //tri
    [stops sortUsingComparator:^NSComparisonResult(StopTime* stop1, StopTime* stop2) {
        return [stop1.tripId compare:stop2.tripId];
    }];
}

#pragma mark CHCSVParserDelegate methods
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    [self.row removeAllObjects];
}

- (void) parser:(CHCSVParser *)parser didEndLine:(NSUInteger)lineNumber {
    if (lineNumber > 1 && self.row.count == 3) {
        // Create and configure a new instance of the StopTime entity.
        StopTime* stopTime = [[StopTime alloc] init];
        stopTime.tripId = self.row[0];
        stopTime.stopId= self.row[1];
        stopTime.stopSequence = self.row[2];
        
        [stops addObject:stopTime];
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
    stops = nil;
}

@end
