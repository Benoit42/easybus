//
//  NSManagedObjectContextTripTest.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <XCTest/XCTest.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"
#import "NSManagedObjectContext+Trip.h"
#import "NSManagedObjectContext+Network.h"
#import "NSManagedObjectContext+Group.h"

@interface NSManagedObjectContextTripTest : XCTestCase

@property(nonatomic) NSManagedObjectContext* managedObjectContext;
@property(nonatomic) RoutesCsvReader* routesCsvReader;
@property(nonatomic) StopsCsvReader* stopsCsvReader;

@end

@implementation NSManagedObjectContextTripTest
objection_requires(@"managedObjectContext", @"routesCsvReader", @"stopsCsvReader")

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
    
    //load data
    NSURL* routesUrl = [[NSBundle mainBundle] URLForResource:@"routes_light" withExtension:@"txt"];
    [self.routesCsvReader loadData:routesUrl];
    NSURL* stopsUrl = [[NSBundle mainBundle] URLForResource:@"stops_light" withExtension:@"txt"];
    [self.stopsCsvReader loadData:stopsUrl];

    //Ajout du jeu de tests
    Route* route64 = [self.managedObjectContext routeForId:@"0064"];
    Route* route164 = [self.managedObjectContext routeForId:@"0164"];
    Stop* stopTimo = [self.managedObjectContext stopForId:@"4001"];
    Stop* stopRepu = [self.managedObjectContext stopForId:@"1167"];
    XCTAssertEqual([[self.managedObjectContext trips] count], 0U, @"Wrong number of trips");
    [self.managedObjectContext addTrip:route64 stop:stopTimo direction:@"0"];
    [self.managedObjectContext addTrip:route64 stop:stopRepu direction:@"1"];
    [self.managedObjectContext addTrip:route164 stop:stopTimo direction:@"0"];
    [self.managedObjectContext addTrip:route164 stop:stopRepu direction:@"1"];
}

- (void)tearDown
{
    [super tearDown];
}

//Test des favoris
- (void)testTrips {
    //Lecture des favoris
    NSArray* trips = [self.managedObjectContext trips];
    
    //Vérifications
    XCTAssertEqual([trips count], 4U, @"Wrong number of trips");
}

//Test de l'ajout
- (void)testAddTrip {
    //Préparation des données
    NSUInteger tripCount = [[self.managedObjectContext trips] count];
    NSUInteger groupCount = [[self.managedObjectContext groups] count];

    //Ajout d'un tripori
    Route* route = [self.managedObjectContext routeForId:@"0200"];
    Stop* stop = [self.managedObjectContext stopForId:@"4001"];
    [self.managedObjectContext addTrip:route stop:stop direction:@"0"];

    //Vérifications
    XCTAssertEqual([[self.managedObjectContext trips] count], tripCount+1, @"Wrong number of trips");
    XCTAssertEqual([[self.managedObjectContext groups] count], groupCount+1, @"Wrong number of groups");
}

//Test de l'ajout d'un doublon
- (void)testAddTripDoublon {
    //Préparation des données
    NSUInteger tripCount = [[self.managedObjectContext trips] count];
    Route* route64 = [self.managedObjectContext routeForId:@"0064"];
    Stop* stopTimo = [self.managedObjectContext stopForId:@"4001"];
    
    //Ajout d'un tripori
    [self.managedObjectContext addTrip:route64 stop:stopTimo direction:@"0"];

    //Vérifications
    XCTAssertEqual([[self.managedObjectContext trips] count], tripCount, @"Wrong number of trips");
}

//Test de la suppression
- (void)testRemoveTrip {
    //Récupération d'un tripori
    NSUInteger tripCount = [[self.managedObjectContext trips] count];
    Trip* trip = [[self.managedObjectContext trips] lastObject];

    //Suppression du tripori
    [self.managedObjectContext deleteObject:trip];
    
    //Vérifications
    XCTAssertEqual([[self.managedObjectContext trips] count], tripCount-1, @"Wrong number of trips");
}

@end
