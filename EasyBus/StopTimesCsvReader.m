//
//  RouteStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "StopTimesCsvReader.h"
#import "CSVParser.h"

@interface StopTimesCsvReader()

@end

@implementation StopTimesCsvReader
objection_register_singleton(StopTimesCsvReader)

@synthesize stops;

- (void)loadData {
    //Chargement des arrêts standards
    NSError* error = nil;
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"stop_times" withExtension:@"txt"];
    NSString *csvString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
    //Allocation du dictionnaire
    self.stops = [[NSMutableArray alloc] init];

    //parsing du fichier
    CSVParser* parser =
    [[CSVParser alloc]
     initWithString:csvString
     separator:@","
     hasHeader:YES
     fieldNames:nil];
    [parser parseRowsForReceiver:self selector:@selector(receiveRecord:)];
    
    //tri
    [stops sortUsingComparator:^NSComparisonResult(StopTime* stop1, StopTime* stop2) {
        return [stop1.tripId compare:stop2.tripId];
    }];
}

- (void)receiveRecord:(NSDictionary *)aRecord
{
    // Create and configure a new instance of the StopTime entity.
    StopTime* stopTime = [[StopTime alloc] init];;
    stopTime.tripId = [aRecord objectForKey:@"trip_id"];
    stopTime.stopId= [aRecord objectForKey:@"stop_id"];
    stopTime.stopSequence = [NSNumber numberWithInt:[[aRecord objectForKey:@"stop_sequence"] intValue] - 1];

    [stops addObject:stopTime];
}

- (void)cleanUp {
    stops = nil;
}

@end
