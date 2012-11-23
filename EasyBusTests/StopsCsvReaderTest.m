//
//  Test.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "StopsCsvReader.h"

@interface StopsCsvReaderTest : SenTestCase

@property(nonatomic) StopsCsvReader* _stopsCsvReader;

@end

@implementation StopsCsvReaderTest

@synthesize _stopsCsvReader;

- (void)setUp
{
    [super setUp];
    _stopsCsvReader = [StopsCsvReader new];
}

- (void)tearDown
{
    [super tearDown];
}


//Basic test
- (void)testStops
{
    STAssertEquals(1367, (int)[[_stopsCsvReader._stops.objectEnumerator allObjects] count], @"Wrong number of stops in stops.txt");
}

@end
