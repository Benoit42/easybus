//
//  StaticDataManagerTest.m
//  EasyBus
//
//  Created by Benoit on 23/06/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "StaticDataManager.h"

@interface StaticDataManagerTest : SenTestCase

@property(nonatomic) StaticDataManager* _staticDataManager;

@end

@implementation StaticDataManagerTest

@synthesize _staticDataManager;

- (void)setUp {
    [super setUp];
    _staticDataManager = [StaticDataManager singleton];
}

- (void)tearDown {
    [super tearDown];
}

//Vérification de la ligne 64
- (void)testRoutes
{
    NSArray* routes = [_staticDataManager routes];
    STAssertTrue([routes count] > 0 , @"Routes shall exist");

    Route* firstRoute = [routes objectAtIndex:0];
    STAssertEqualObjects(@"0001", firstRoute.id, @"First route shall be 0001");


    Route* lastRoute = [routes lastObject];
    STAssertEqualObjects(@"0805", lastRoute.id, @"First route shall be 0805");
}

@end
