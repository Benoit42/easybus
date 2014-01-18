//
//  RoutesStopsCsvReaderTest.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <XCTest/XCTest.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "RoutesStopsCsvReader.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"

@interface RoutesStopsCsvReaderTest : XCTestCase

@property(nonatomic) RoutesStopsCsvReader* routesStopsCsvReader;

@end

@implementation RoutesStopsCsvReaderTest

objection_requires(@"routesStopsCsvReader")

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
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCountRoutesStops
{
    //Load data
    NSURL* routesStopsUrl = [[NSBundle mainBundle] URLForResource:@"routes_stops_light" withExtension:@"txt"];
    [self.routesStopsCsvReader loadData:routesStopsUrl];

    //Test result
    int count = [self.routesStopsCsvReader.routesStops count];
    XCTAssertEqual(count, 95, @"Wrong number of stopTimes");
}

@end
