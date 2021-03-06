//
//  Test.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CoreData/CoreData.h>
#import <XCTest/XCTest.h>
#import <CHCSVParser/CHCSVParser.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "StopTimesCsvReader.h"

@interface StopTimesCsvReaderTest : XCTestCase

@property(nonatomic) StopTimesCsvReader* stopTimesCsvReader;

@end

@implementation StopTimesCsvReaderTest
objection_requires(@"stopTimesCsvReader")

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
    NSURL* stopTimesUrl = [[NSBundle mainBundle] URLForResource:@"stop_times_light" withExtension:@"txt"];
    [self.stopTimesCsvReader loadData:stopTimesUrl];
}

- (void)tearDown
{
    [super tearDown];
}

//Comptage des occurences
- (void)testCountStopTimes {
    int count = [self.stopTimesCsvReader.stopTimes count];
    XCTAssertEqual(count, 10034, @"Wrong number of stopTimes");
}

@end
