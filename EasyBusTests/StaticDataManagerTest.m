//
//  StaticDataManagerTest.m
//  EasyBus
//
//  Created by Benoit on 23/06/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <XCTest/XCTest.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "StaticDataManager.h"
#import "StaticDataLoader.h"

@interface StaticDataManagerTest : XCTestCase

@property(nonatomic) StaticDataManager* staticDataManager;
@property(nonatomic) StaticDataLoader* staticDataLoader;

@end

@implementation StaticDataManagerTest

objection_requires(@"staticDataManager", @"staticDataLoader")
@synthesize staticDataManager, staticDataLoader;

- (void)setUp {
    [super setUp];
    
    //IoC
    JSObjectionModule* iocModule = [[IoCModule alloc] init];
    JSObjectionModule* iocModuleTest = [[IoCModuleTest alloc] init];
    JSObjectionInjector *injector = [JSObjection createInjectorWithModules:iocModule, iocModuleTest, nil];
    [JSObjection setDefaultInjector:injector];
    
    //Inject dependencies
    [[JSObjection defaultInjector] injectDependencies:self];
    
//    NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] init];
//    NSPersistentStoreCoordinator *coordinator = self.staticDataManager.managedObjectContext.persistentStoreCoordinator;
//    [importContext setPersistentStoreCoordinator:coordinator];
//    [importContext setUndoManager:nil];
//    self.staticDataManager.managedObjectContext = importContext;
//    self.staticDataLoader.managedObjectContext = importContext;
//    self.staticDataLoader.routesCsvReader.managedObjectContext = importContext;
//    self.staticDataLoader.stopsCsvReader.managedObjectContext = importContext;
    
    //Load data
    [self.staticDataLoader loadStaticData];
}

- (void)tearDown {
    [super tearDown];
}

//Vérification des routes
- (void)testRoutes {
    NSArray* routes = [self.staticDataManager routes];
    XCTAssertTrue([routes count] > 0 , @"Routes shall exist");

    Route* firstRoute = [routes objectAtIndex:0];
    XCTAssertEqualObjects(@"0001", firstRoute.id, @"First route shall be 0001");

    Route* lastRoute = [routes lastObject];
    XCTAssertEqualObjects(@"0805", lastRoute.id, @"First route shall be 0805");
}


- (void)testRoute64 {
    Route* route64 = [self.staticDataManager routeForId:@"0064"];
    XCTAssertNotNil(route64 , @"Route 64 shall exists");

    NSArray* stopsDirectionZero = [self.staticDataManager stopsForRoute:route64 direction:@"0"];
    XCTAssertEqual(stopsDirectionZero.count, 22U, @"Wrong number of stops");

    NSArray* stopsDirectionOne = [self.staticDataManager stopsForRoute:route64 direction:@"1"];
    XCTAssertEqual(stopsDirectionOne.count, 23U, @"Wrong number of stops");

    Stop* republique1 = stopsDirectionZero[0];
    XCTAssertEqualObjects(republique1.name, @"Timonière", @"Wrong stop name");
    Stop* timoniere1 = stopsDirectionZero[21];
    XCTAssertEqualObjects(timoniere1.name, @"République Pré Botté", @"Wrong stop name");

    Stop* timoniere2 = stopsDirectionOne[0];
    XCTAssertEqualObjects(timoniere2.name, @"République Pré Botté", @"Wrong stop name");
    Stop* republique2 = stopsDirectionOne[22];
    XCTAssertEqualObjects(republique2.name, @"Timonière", @"Wrong stop name");
}



@end
