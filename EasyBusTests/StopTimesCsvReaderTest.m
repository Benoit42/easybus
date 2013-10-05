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
#import "StopTimesCsvReader.h"

@interface StopTimesCsvReaderTest : SenTestCase

@property(nonatomic) StopTimesCsvReader* stopTimesCsvReader;

@end

@implementation StopTimesCsvReaderTest

objection_requires(@"stopTimesCsvReader")
@synthesize stopTimesCsvReader;

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
    [self.stopTimesCsvReader loadData];
}

- (void)tearDown
{
    [super tearDown];
}

//Comptage des occurences
- (void)testCountStopTimes {
    int count = [stopTimesCsvReader.stops count];
    STAssertEquals(count, 589504, @"Wrong number of stopTimes in stop_times");
}

@end
