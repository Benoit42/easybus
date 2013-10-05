//
//  StaticDataManagerTest.m
//  EasyBus
//
//  Created by Benoit on 23/06/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <SenTestingKit/SenTestingKit.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "StaticDataManager.h"

@interface StaticDataManagerTest : SenTestCase

@property(nonatomic) StaticDataManager* staticDataManager;

@end

@implementation StaticDataManagerTest

objection_requires(@"staticDataManager")
@synthesize staticDataManager;

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
    [self.staticDataManager reloadDatabase];
}

- (void)tearDown {
    [super tearDown];
}

//Vérification des routes
- (void)testRoutes
{
    NSArray* routes = [self.staticDataManager routes];
    STAssertTrue([routes count] > 0 , @"Routes shall exist");

    Route* firstRoute = [routes objectAtIndex:0];
    STAssertEqualObjects(@"0001", firstRoute.id, @"First route shall be 0001");

    Route* lastRoute = [routes lastObject];
    STAssertEqualObjects(@"0805", lastRoute.id, @"First route shall be 0805");
}


- (void)testRoute64
{
    Route* route64 = [self.staticDataManager routeForId:@"0064"];
    STAssertNotNil(route64 , @"Route 64 shall exists");
    STAssertEquals(route64.stopsDirectionZero.count, 22U, @"Wrong number of stops");
    STAssertEquals(route64.stopsDirectionOne.count, 23U, @"Wrong number of stops");
}



@end
