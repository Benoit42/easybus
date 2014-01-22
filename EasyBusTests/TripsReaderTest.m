//
//  Test.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <XCTest/XCTest.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "TripsCsvReader.h"

@interface TripsCsvReaderTest : XCTestCase

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
    NSURL* tripsUrl = [[NSBundle mainBundle] URLForResource:@"trips_light" withExtension:@"txt"];
    [self.tripsCsvReader loadData:tripsUrl];
}

- (void)tearDown
{
    [super tearDown];
}

//Comptage des occurences
- (void)testCountTrips {
    int count = [self.tripsCsvReader.trips count];
    XCTAssertEqual(count, 494, @"Wrong number of trips");
}

//Vérification des libellés des terminus
- (void)testCheckTerminusLabels {
    XCTAssertEqualObjects(@"64 | Rennes République", [self.tripsCsvReader terminusLabelForRouteId:@"0064" andDirectionId:@"0"], @"Wrong terminus label");
    XCTAssertEqualObjects(@"64 | Acigné", [self.tripsCsvReader terminusLabelForRouteId:@"0064" andDirectionId:@"1"], @"Wrong terminus label");
    XCTAssertEqualObjects(@"164 | Rennes République", [self.tripsCsvReader terminusLabelForRouteId:@"0164" andDirectionId:@"0"], @"Wrong terminus label");
    XCTAssertEqualObjects(@"164 | Acigné", [self.tripsCsvReader terminusLabelForRouteId:@"0164" andDirectionId:@"1"], @"Wrong terminus label");
    XCTAssertEqualObjects(@"200 | Rennes Lycée Assomption", [self.tripsCsvReader terminusLabelForRouteId:@"0200" andDirectionId:@"0"], @"Wrong terminus label");
    XCTAssertEqualObjects(@"200 | Acigné", [self.tripsCsvReader terminusLabelForRouteId:@"0200" andDirectionId:@"1"], @"Wrong terminus label");
}

@end
