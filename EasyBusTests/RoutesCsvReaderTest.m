//
//  RoutesCsvReaderTest.m
//  EasyBus
//
//  Created by Benoit on 22/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RoutesCsvReader.h"

@interface RoutesCsvReaderTest : SenTestCase

@property(nonatomic) RoutesCsvReader* _routesCsvReader;

@end

@implementation RoutesCsvReaderTest

@synthesize _routesCsvReader;

- (void)setUp
{
    [super setUp];
    _routesCsvReader = [RoutesCsvReader new];
}

- (void)tearDown
{
    [super tearDown];
}


//Comptage des occurences
- (void)testCountRoutes
{
    STAssertEquals(62, (int)_routesCsvReader._routes.count, @"Wrong number of routes in routes.txt");
}

//Vérification de la ligne 64
- (void)testRoute0064
{
    Route* route64 = [_routesCsvReader._routesMap objectForKey:@"0064"];
    STAssertNotNil(route64, @"Route with id 0064 shall not be nil");
    STAssertEqualObjects(@"0064", route64._id, @"Wrong id for route 0064");
    STAssertEqualObjects(@"64", route64._shortName, @"Wrong short name for route 0064");
    STAssertEqualObjects(@"Rennes (République) <> Acigné", route64._longName, @"Wrong long name for route 0064");
    STAssertEqualObjects(@"Rennes", route64._fromName, @"Wrong from name for route 0064");
    STAssertEqualObjects(@"Acigné", route64._toName, @"Wrong to name for route 0064");
}

@end
