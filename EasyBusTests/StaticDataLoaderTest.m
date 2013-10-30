//
//  StaticDataLoaderTest.m
//  EasyBus
//
//  Created by Benoit on 30/10/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <XCTest/XCTest.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "StaticDataLoader.h"

@interface StaticDataLoaderTest : XCTestCase

@property(nonatomic) StaticDataLoader* staticDataLoader;
@property(nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation StaticDataLoaderTest

objection_requires(@"managedObjectContext", @"staticDataLoader")

- (void)setUp {
    [super setUp];
    
    //IoC
    JSObjectionModule* iocModule = [[IoCModule alloc] init];
    JSObjectionModule* iocModuleTest = [[IoCModuleTest alloc] init];
    JSObjectionInjector *injector = [JSObjection createInjectorWithModules:iocModule, iocModuleTest, nil];
    [JSObjection setDefaultInjector:injector];
    
    //Inject dependencies
    [[JSObjection defaultInjector] injectDependencies:self];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testMatchTripsAndStops {
    //Prepare routes
    Route* route1 = (Route *)[NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
    route1.id = @"route1";

    Route* route2 = (Route *)[NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
    route2.id = @"route2";

    //Prepare stops
    Stop* stop11 = (Stop*)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
    stop11.id = @"stop11";
    Stop* stop12 = (Stop*)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
    stop12.id = @"stop12";
    Stop* stop13 = (Stop*)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
    stop13.id = @"stop13";
    NSOrderedSet* stops10 = [[NSMutableOrderedSet alloc] initWithArray:@[stop11, stop12, stop13]];
    NSOrderedSet* stops11 = [[NSMutableOrderedSet alloc] initWithArray:@[stop13, stop12, stop11]];

    Stop* stop21 = (Stop*)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
    stop21.id = @"stop21";
    Stop* stop22 = (Stop*)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
    stop22.id = @"stop22";
    Stop* stop23 = (Stop*)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
    stop23.id = @"stop23";
    NSOrderedSet* stops20 = [[NSMutableOrderedSet alloc] initWithArray:@[stop21, stop22, stop23]];
    NSOrderedSet* stops21 = [[NSMutableOrderedSet alloc] initWithArray:@[stop23, stop22, stop21]];

    //Prepare trips
    Trip* trip10 = [[Trip alloc] init];
    trip10.id = @"trip10";
    trip10.routeId = route1.id;
    trip10.directionId = @"0";

    Trip* trip11 = [[Trip alloc] init];
    trip11.id = @"trip11";
    trip11.routeId = route1.id;
    trip11.directionId = @"1";

    Trip* trip20 = [[Trip alloc] init];
    trip20.id = @"trip20";
    trip20.routeId = route2.id;
    trip20.directionId = @"0";
    
    Trip* trip21 = [[Trip alloc] init];
    trip21.id = @"trip21";
    trip21.routeId = route2.id;
    trip21.directionId = @"1";
    
    NSMutableArray* trips = [@[trip10, trip11, trip20, trip21] mutableCopy];

    //Prepare StopTimes for route 1 direction 0
    StopTime* stopTime101 = [[StopTime alloc] init];
    stopTime101.tripId = trip10.id;
    stopTime101.stopId= stop11.id;
    stopTime101.stopSequence = [NSNumber numberWithInteger:1];

    StopTime* stopTime102 = [[StopTime alloc] init];
    stopTime102.tripId = trip10.id;
    stopTime102.stopId= stop12.id;
    stopTime102.stopSequence = [NSNumber numberWithInteger:2];

    StopTime* stopTime103 = [[StopTime alloc] init];
    stopTime103.tripId = trip10.id;
    stopTime103.stopId= stop13.id;
    stopTime103.stopSequence = [NSNumber numberWithInteger:3];

    //Prepare StopTimes for route 1 direction 1
    StopTime* stopTime111 = [[StopTime alloc] init];
    stopTime111.tripId = trip11.id;
    stopTime111.stopId= stop11.id;
    stopTime111.stopSequence = [NSNumber numberWithInteger:3];
    
    StopTime* stopTime112 = [[StopTime alloc] init];
    stopTime112.tripId = trip11.id;
    stopTime112.stopId= stop12.id;
    stopTime112.stopSequence = [NSNumber numberWithInteger:2];
    
    StopTime* stopTime113 = [[StopTime alloc] init];
    stopTime113.tripId = trip11.id;
    stopTime113.stopId= stop13.id;
    stopTime113.stopSequence = [NSNumber numberWithInteger:1];

    //Prepare StopTimes for route 2 direction 0
    StopTime* stopTime201 = [[StopTime alloc] init];
    stopTime201.tripId = trip20.id;
    stopTime201.stopId= stop21.id;
    stopTime201.stopSequence = [NSNumber numberWithInteger:1];
    
    StopTime* stopTime202 = [[StopTime alloc] init];
    stopTime202.tripId = trip20.id;
    stopTime202.stopId= stop22.id;
    stopTime202.stopSequence = [NSNumber numberWithInteger:2];
    
    StopTime* stopTime203 = [[StopTime alloc] init];
    stopTime203.tripId = trip20.id;
    stopTime203.stopId= stop23.id;
    stopTime203.stopSequence = [NSNumber numberWithInteger:3];
    
    //Prepare StopTimes for route 1 direction 1
    StopTime* stopTime211 = [[StopTime alloc] init];
    stopTime211.tripId = trip21.id;
    stopTime211.stopId= stop21.id;
    stopTime211.stopSequence = [NSNumber numberWithInteger:3];
    
    StopTime* stopTime212 = [[StopTime alloc] init];
    stopTime212.tripId = trip21.id;
    stopTime212.stopId= stop22.id;
    stopTime212.stopSequence = [NSNumber numberWithInteger:2];
    
    StopTime* stopTime213 = [[StopTime alloc] init];
    stopTime213.tripId = trip21.id;
    stopTime213.stopId= stop23.id;
    stopTime213.stopSequence = [NSNumber numberWithInteger:1];

    NSMutableArray* stopTimes = [@[stopTime101, stopTime102, stopTime103, stopTime111, stopTime112, stopTime113, stopTime201, stopTime202, stopTime203, stopTime211, stopTime212, stopTime213] mutableCopy];

    //Randomize arrays
    for (int i = 0; i < trips.count; i++) {
        int randomInt1 = arc4random() % [trips count];
        int randomInt2 = arc4random() % [trips count];
        [trips exchangeObjectAtIndex:randomInt1 withObjectAtIndex:randomInt2];
    }
    for (int i = 0; i < stopTimes.count; i++) {
        int randomInt1 = arc4random() % [stopTimes count];
        int randomInt2 = arc4random() % [stopTimes count];
        [stopTimes exchangeObjectAtIndex:randomInt1 withObjectAtIndex:randomInt2];
    }

    //Match trips and stopTimes
    [self.staticDataLoader matchTrips:trips andStops:stopTimes];
    
    //Verify data
    XCTAssertTrue([route1.stopsDirectionZero isEqualToOrderedSet:stops10], @"Wrong stops for route 1 direction 0");
    XCTAssertTrue([route1.stopsDirectionOne isEqualToOrderedSet:stops11], @"Wrong stops for route 1 direction 1");
    XCTAssertTrue([route2.stopsDirectionZero isEqualToOrderedSet:stops20], @"Wrong stops for route 2 direction 0");
    XCTAssertTrue([route2.stopsDirectionOne isEqualToOrderedSet:stops21], @"Wrong stops for route 2 direction 1");
}
@end
