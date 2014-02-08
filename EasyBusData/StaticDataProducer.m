//
//  StaticDataManager.m
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TripsCsvReader.h"
#import "StopTimesCsvReader.h"
#import "StaticDataLoader.h"
#import "RouteStop.h"

@interface StaticDataProducer : XCTestCase

@property(nonatomic) TripsCsvReader* tripsCsvReader;
@property(nonatomic) StopTimesCsvReader* stopTimesCsvReader;
@property(nonatomic) StaticDataLoader* staticDataLoader;

@end

@implementation StaticDataProducer

- (void)setUp
{
    [super setUp];
    
    self.tripsCsvReader = [[TripsCsvReader alloc] init];
    self.stopTimesCsvReader = [[StopTimesCsvReader alloc] init];
    self.staticDataLoader = [[StaticDataLoader alloc] init];
}

- (void)testComputeData {
    //Pré-conditions
    NSParameterAssert(self.tripsCsvReader);
    NSParameterAssert(self.stopTimesCsvReader);
    NSParameterAssert(self.staticDataLoader);

    //Load data
    NSURL* tripsUrl = [[NSBundle mainBundle] URLForResource:@"trips" withExtension:@"txt"];
    [self.tripsCsvReader loadData:tripsUrl];
    
    NSURL* stopTimesUrl = [[NSBundle mainBundle] URLForResource:@"stop_times" withExtension:@"txt"];
    [self.stopTimesCsvReader loadData:stopTimesUrl];
    
    //Compute route/stops association
    NSArray* routesStops = [self.staticDataLoader matchTrips:self.tripsCsvReader.trips andStops:self.stopTimesCsvReader.stopTimes];

    //Save data
    [self saveRoutesStops:routesStops];
    [self saveTerminus:self.tripsCsvReader.terminus];
}

// Association route/stop
- (void) saveRoutesStops:(NSArray*)routesStops {
    //Log
    NSLog(@"Génération du fichier routes_stops.txt");
    
    //Sauvegarde
    [routesStops enumerateObjectsUsingBlock:^(RouteStop* routeStop, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@", [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\",\"%@\"", routeStop.routeId, routeStop.stopId, routeStop.directionId, routeStop.stopSequence]);
    }];
    
    //Retour
    return;
}

// Terminus
- (void) saveTerminus:(NSDictionary*)terminus {
    //Log
    NSLog(@"Génération du fichier terminus.json");
    
    //Sauvegarde
    NSLog(@"{");
    [terminus enumerateKeysAndObjectsUsingBlock:^(NSString* routeId, NSDictionary* labels, BOOL *stop) {
        NSLog(@"%@", [NSString stringWithFormat:@"\"%@\":{\"0\":\"%@\",\"1\":\"%@\"},", routeId, labels[@"0"], labels[@"1"]]);
    }];
    
    //Retour
    return;
}

@end
