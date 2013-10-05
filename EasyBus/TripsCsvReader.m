//
//  RouteStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "TripsCsvReader.h"
#import "CSVParser.h"

@implementation TripsCsvReader
objection_register_singleton(TripsCsvReader)

@synthesize trips;

- (void)loadData {
    //Chargement des arrêts standards
    NSError* error = nil;
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"trips" withExtension:@"txt"];
    NSString *csvString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];

    //Allocation du dictionnaire
    self.trips = [[NSMutableArray alloc] init];
    
    //parsing du fichier
    CSVParser* parser =
    [[CSVParser alloc]
     initWithString:csvString
     separator:@","
     hasHeader:YES
     fieldNames:nil];
    [parser parseRowsForReceiver:self selector:@selector(receiveRecord:)];
    
    //tri
    [trips sortUsingComparator:^NSComparisonResult(Trip* trip1, Trip* trip2) {
        return [trip1.id compare:trip2.id];
    }];
}

- (void)receiveRecord:(NSDictionary *)aRecord {
    // Create and configure a new instance of the Trip entity.
    Trip* trip = [[Trip alloc] init];
    trip.id = [aRecord objectForKey:@"trip_id"];
    trip.routeId = [aRecord objectForKey:@"route_id"];
    trip.directionId = [aRecord objectForKey:@"direction_id"];
    
    [trips addObject:trip];
}

@end
