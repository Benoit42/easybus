//
//  StaticDataManagerTest.m
//  EasyBus
//
//  Created by Benoit on 23/06/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CoreLocation/CoreLocation.h>
#import <XCTest/XCTest.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "StaticDataLoader.h"
#import "NSManagedObjectContext+Network.h"

@interface NSManagedObjectContextNetworkTest : XCTestCase

@property(nonatomic) NSManagedObjectContext* managedObjectContext;
@property(nonatomic) StaticDataLoader* staticDataLoader;

@end

@implementation NSManagedObjectContextNetworkTest
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
    
    //Load data
    [self.staticDataLoader loadDataFromLocalFiles:[[NSBundle mainBundle] bundleURL]];
}

- (void)tearDown {
    [super tearDown];
}

//Vérification des routes
- (void)testRoutes {
    NSArray* routes = [self.managedObjectContext routes];
    XCTAssertEqual(routes.count, 94U, @"Wrong number of routes");

    Route* route64 = [self.managedObjectContext routeForId:@"0064"];
    XCTAssertNotNil(route64 , @"Route 64 shall exists");
    
    NSArray* stopsDirectionZero = [self.managedObjectContext stopsForRoute:route64 direction:@"0"];
    XCTAssertEqual(stopsDirectionZero.count, 22U, @"Wrong number of stops");
    
    NSArray* stopsDirectionOne = [self.managedObjectContext stopsForRoute:route64 direction:@"1"];
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

//Vérification des arrêts
- (void)testStops {
    NSArray* stops = [self.managedObjectContext stops];
    XCTAssertEqual(stops.count, 1409U, @"Wrong number of stos");
}

- (void)testStopsSortedByDistance {
    CLLocation* maison = [[CLLocation alloc] initWithLatitude:+48.138149 longitude:-1.523640];
    NSArray* stopsFromMaison = [self.managedObjectContext stopsSortedByDistanceFrom:maison];
    XCTAssertEqualObjects(((Stop*)stopsFromMaison[0]).name, @"Timonière", @"Wrong stop name");
    XCTAssertEqualObjects(((Stop*)stopsFromMaison[1]).name, @"Verdaudais", @"Wrong stop name");
    XCTAssertEqualObjects(((Stop*)stopsFromMaison[2]).name, @"Verdaudais", @"Wrong stop name");
    XCTAssertEqualObjects(((Stop*)stopsFromMaison[3]).name, @"Acigné Mairie", @"Wrong stop name");
    XCTAssertEqualObjects(((Stop*)stopsFromMaison[4]).name, @"Acigné Mairie", @"Wrong stop name");
    
    CLLocation* bureau = [[CLLocation alloc] initWithLatitude:+48.127327 longitude:-1.627679];
    NSArray* stopsFromBureau = [self.managedObjectContext stopsSortedByDistanceFrom:bureau];
    XCTAssertEqualObjects(((Stop*)stopsFromBureau[0]).name, @"Clos Courtel", @"Wrong stop name");
    XCTAssertEqualObjects(((Stop*)stopsFromBureau[1]).name, @"Clos Courtel", @"Wrong stop name");
    XCTAssertEqualObjects(((Stop*)stopsFromBureau[6]).name, @"Belle Fontaine", @"Wrong stop name");
    XCTAssertEqualObjects(((Stop*)stopsFromBureau[7]).name, @"Cesson Hôpital Privé", @"Wrong stop name");
}

@end
