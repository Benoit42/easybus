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
#import "NSMutableArray+Randomize.h"

@interface StaticDataLoaderLocalTest : XCTestCase

@property(nonatomic) StaticDataLoader* staticDataLoader;
@property(nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation StaticDataLoaderLocalTest

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

- (void)testMatchRoutesStops {
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

    //Prepare routesStops
    RouteStop* rs101 = [[RouteStop alloc] init];
    rs101.routeId = @"route1";
    rs101.stopId = @"stop11";
    rs101.directionId = @"0";
    rs101.stopSequence = [NSNumber numberWithInt:1];

    RouteStop* rs102 = [[RouteStop alloc] init];
    rs102.routeId = @"route1";
    rs102.stopId = @"stop12";
    rs102.directionId = @"0";
    rs102.stopSequence = [NSNumber numberWithInt:2];

    RouteStop* rs103 = [[RouteStop alloc] init];
    rs103.routeId = @"route1";
    rs103.stopId = @"stop13";
    rs103.directionId = @"0";
    rs103.stopSequence = [NSNumber numberWithInt:3];

    RouteStop* rs111 = [[RouteStop alloc] init];
    rs111.routeId = @"route1";
    rs111.stopId = @"stop11";
    rs111.directionId = @"1";
    rs111.stopSequence = [NSNumber numberWithInt:3];
    
    RouteStop* rs112 = [[RouteStop alloc] init];
    rs112.routeId = @"route1";
    rs112.stopId = @"stop12";
    rs112.directionId = @"1";
    rs112.stopSequence = [NSNumber numberWithInt:2];
    
    RouteStop* rs113 = [[RouteStop alloc] init];
    rs113.routeId = @"route1";
    rs113.stopId = @"stop13";
    rs113.directionId = @"1";
    rs113.stopSequence = [NSNumber numberWithInt:1];

    RouteStop* rs201 = [[RouteStop alloc] init];
    rs201.routeId = @"route2";
    rs201.stopId = @"stop21";
    rs201.directionId = @"0";
    rs201.stopSequence = [NSNumber numberWithInt:1];
    
    RouteStop* rs202 = [[RouteStop alloc] init];
    rs202.routeId = @"route2";
    rs202.stopId = @"stop22";
    rs202.directionId = @"0";
    rs202.stopSequence = [NSNumber numberWithInt:2];
    
    RouteStop* rs203 = [[RouteStop alloc] init];
    rs203.routeId = @"route2";
    rs203.stopId = @"stop23";
    rs203.directionId = @"0";
    rs203.stopSequence = [NSNumber numberWithInt:3];
    
    RouteStop* rs211 = [[RouteStop alloc] init];
    rs211.routeId = @"route2";
    rs211.stopId = @"stop21";
    rs211.directionId = @"1";
    rs211.stopSequence = [NSNumber numberWithInt:3];
    
    RouteStop* rs212 = [[RouteStop alloc] init];
    rs212.routeId = @"route2";
    rs212.stopId = @"stop22";
    rs212.directionId = @"1";
    rs212.stopSequence = [NSNumber numberWithInt:2];
    
    RouteStop* rs213 = [[RouteStop alloc] init];
    rs213.routeId = @"route2";
    rs213.stopId = @"stop23";
    rs213.directionId = @"1";
    rs213.stopSequence = [NSNumber numberWithInt:1];
    
    //Randomize arrays
    NSMutableArray* routesStops = [@[rs101, rs102, rs103, rs111, rs112, rs113, rs201, rs202, rs203, rs211, rs212, rs213] mutableCopy] ;
    [routesStops randomize];
    
    //Match routes and stops
    [self.staticDataLoader matchRoutesAndStops:routesStops];
    
    //Verify data
    XCTAssertTrue([route1.stopsDirectionZero isEqualToOrderedSet:stops10], @"Wrong stops for route 1 direction 0");
    XCTAssertTrue([route1.stopsDirectionOne isEqualToOrderedSet:stops11], @"Wrong stops for route 1 direction 1");
    XCTAssertTrue([route2.stopsDirectionZero isEqualToOrderedSet:stops20], @"Wrong stops for route 2 direction 0");
    XCTAssertTrue([route2.stopsDirectionOne isEqualToOrderedSet:stops21], @"Wrong stops for route 2 direction 1");
}
@end
