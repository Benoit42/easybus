//
//  Test.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <SenTestingKit/SenTestingKit.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "TripsCsvReader.h"

@interface TripsCsvReaderTest : SenTestCase

@property(nonatomic) TripsCsvReader* tripsCsvReader;

@end

@implementation TripsCsvReaderTest

objection_requires(@"tripsCsvReader")
@synthesize tripsCsvReader;

- (void)setUp
{
    [super setUp];
    
    //IoC
    JSObjectionModule* iocModule = [[IoCModule alloc] init];
    JSObjectionModule* iocModuleTest = [[IoCModuleTest alloc] init];
    JSObjectionInjector *injector = [JSObjection createInjectorWithModules:iocModule, iocModuleTest, nil];
    [JSObjection setDefaultInjector:injector];
    
    //Inject dependencies
    [[JSObjection defaultInjector] injectDependencies:self];
    
    //Load data
    [self.tripsCsvReader loadData];
}

- (void)tearDown
{
    [super tearDown];
}

//Comptage des occurences
- (void)testCountTrips {
    int count = [self.tripsCsvReader.trips count];
    STAssertEquals(count, 22388, @"Wrong number of trips in trips.txt");
}

//Vérification de la ligne 64
- (void)testTrips1 {
    NSArray* trips = self.tripsCsvReader.trips;
    STAssertTrue([trips count] > 0 , @"Trip with id 1 shall exists");
    Trip* trip1 = [trips objectAtIndex:0];
    
    STAssertEqualObjects(trip1.id, @"1", @"Wrong id");
    STAssertEqualObjects(trip1.routeId, @"0052", @"Wrong route_id");
    STAssertEqualObjects(trip1.directionId, @"0", @"Wrong direction_id");
}

@end
