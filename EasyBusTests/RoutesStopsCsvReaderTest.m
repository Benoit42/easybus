//
//  RoutesStopsCsvReaderTest.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RoutesStopsCsvReader.h"

@interface RoutesStopsCsvReaderTest : SenTestCase

@property(nonatomic) RoutesStopsCsvReader* _routesStopsCsvReader;

@end

@implementation RoutesStopsCsvReaderTest

@synthesize _routesStopsCsvReader;

- (void)setUp
{
    [super setUp];
    _routesStopsCsvReader = [RoutesStopsCsvReader new];
}

- (void)tearDown
{
    [super tearDown];
}


//Basic test
- (void)testRoutes
{
    NSArray* stops = [_routesStopsCsvReader._routeStops objectForKey:@"0064-0"];
    STAssertNotNil(stops, @"Wrong number of stops for route 64 in routes_stops.txt");
    STAssertEquals(22, (int)stops.count, @"Wrong number of stops for route 64 in routes_stops.txt");


    stops = [_routesStopsCsvReader._routeStops objectForKey:@"0164-0"];
    STAssertNotNil(stops, @"Wrong number of stops for route 164 in routes_stops.txt");
    STAssertEquals(8, (int)stops.count, @"Wrong number of stops for route 164 in routes_stops.txt");
}

@end
