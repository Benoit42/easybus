//
//  DeparturesManagerTest.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "DeparturesManager.h"
#import "Favorite.h"
#import "NSURLProtocolStub.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"

@interface DeparturesManagerTest : AsyncTestCase

@property(nonatomic) NSManagedObjectContext* managedObjectContext;
@property(nonatomic) DeparturesManager* departuresManager;
@property(nonatomic) RoutesCsvReader* routesCsvReader;
@property(nonatomic) StopsCsvReader* stopsCsvReader;

@end

@implementation DeparturesManagerTest
objection_requires(@"managedObjectContext", @"departuresManager", @"routesCsvReader", @"stopsCsvReader")

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
    
    //Préconditions
    NSCParameterAssert(self.managedObjectContext);
    NSCParameterAssert(self.departuresManager);
    NSCParameterAssert(self.routesCsvReader);
    NSCParameterAssert(self.stopsCsvReader);
    
    //load data
    NSURL* routesUrl = [[NSBundle mainBundle] URLForResource:@"routes_light" withExtension:@"txt"];
    [self.routesCsvReader loadData:routesUrl];
    NSURL* stopsUrl = [[NSBundle mainBundle] URLForResource:@"stops_light" withExtension:@"txt"];
    [self.stopsCsvReader loadData:stopsUrl];
}

- (void)tearDown
{
    [super tearDown];
}

//Test du cas droit
- (void)testGetDepartures
{
    //Stub de l'url des départs
    [NSURLProtocol registerClass:[NSURLProtocolStub class]];
    NSString* url = @"http://data.keolis-rennes.com/xml/?cmd=getbusnextdepartures";
    [NSURLProtocolStub bindUrl:url toResource:@"getbusnextdepartures.xml"];
    [NSURLProtocolStub configureUrl:url withHeaders:@{@"Content-Type": @"application/xml; charset=UTF-8"}];
    
    //Création des favoris
    Favorite* fav1 = (Favorite *)[NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext];

    //Recherche des départs
    [self runTestWithBlock:^{
        [self.departuresManager refreshDepartures:@[fav1]];
    }
    waitingForNotifications:@[@"departuresUpdateSucceeded"]
               withTimeout:5
     ];
    NSArray* departures = [self.departuresManager getDepartures];
    XCTAssertEqual(7, (int)[departures count], @"Wrong number of departures");
    int index = 0;
    Depart* depart = departures[index++];
    XCTAssertEqualObjects(@"0064", depart.route.id, @"Wrong route id");
    XCTAssertEqualObjects(@"1", depart._direction, @"Wrong direction");
    depart = departures[index++];
    XCTAssertEqualObjects(@"0064", depart.route.id, @"Wrong route id");
    XCTAssertEqualObjects(@"1", depart._direction, @"Wrong direction");
    depart = departures[index++];
    XCTAssertEqualObjects(@"0064", depart.route.id, @"Wrong route id");
    XCTAssertEqualObjects(@"1", depart._direction, @"Wrong direction");
    depart = departures[index++];
    XCTAssertEqualObjects(@"0164", depart.route.id, @"Wrong route id");
    XCTAssertEqualObjects(@"1", depart._direction, @"Wrong direction");
    depart = departures[index++];
    XCTAssertEqualObjects(@"0164", depart.route.id, @"Wrong route id");
    XCTAssertEqualObjects(@"1", depart._direction, @"Wrong direction");
    depart = departures[index++];
    XCTAssertEqualObjects(@"0064", depart.route.id, @"Wrong route id");
    XCTAssertEqualObjects(@"0", depart._direction, @"Wrong direction");
    depart = departures[index++];
    XCTAssertEqualObjects(@"0164", depart.route.id, @"Wrong route id");
    XCTAssertEqualObjects(@"0", depart._direction, @"Wrong direction");
}

//Test du cas droit 2 avec lignes 64, 164 et 200
- (void)testGetDeparturesForGroup
{
    //Stub de l'url des départs
    [NSURLProtocol registerClass:[NSURLProtocolStub class]];
    NSString* url = @"http://data.keolis-rennes.com/xml/?cmd=getbusnextdepartures";
    [NSURLProtocolStub bindUrl:url toResource:@"getbusnextdepartures2.xml"];
    [NSURLProtocolStub configureUrl:url withHeaders:@{@"Content-Type": @"application/xml; charset=UTF-8"}];
    
    //Création des favoris et groupe
    Route* route64 = (Route *)[NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
    route64.id = @"0064";
    Route* route164 = (Route *)[NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
    route164.id = @"0164";
    Route* route200 = (Route *)[NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
    route200.id = @"0200";
    Stop* stopClosCourtel = (Stop*)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
    stopClosCourtel.id = @"2046";

    Favorite* fav64 = (Favorite *)[NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext];
    fav64.route = route64;
    fav64.stop = stopClosCourtel;
    fav64.direction = @"1";
    Favorite* fav164 = (Favorite *)[NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext];
    fav164.route = route164;
    fav164.stop = stopClosCourtel;
    fav164.direction = @"1";
    Favorite* fav200 = (Favorite *)[NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext];
    fav200.route = route200;
    fav200.stop = stopClosCourtel;
    fav200.direction = @"1";
    
    Group* group = (Group *)[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
    [group addFavoritesObject:fav64];
    [group addFavoritesObject:fav164];
    [group addFavoritesObject:fav200];
    
    //Recherche des départs
    [self runTestWithBlock:^{
        [self.departuresManager refreshDepartures:@[fav64, fav164, fav200]];
    }
   waitingForNotifications:@[@"departuresUpdateSucceeded"]
               withTimeout:5
     ];
    
    NSArray* departures = [self.departuresManager getDeparturesForGroupe:group];
    XCTAssertEqual(4, (int)[departures count], @"Wrong number of departures");
    XCTAssertEqualObjects(@"0064", ((Depart*)departures[0]).route.id, @"Wrong route id");
    XCTAssertEqualObjects(@"0164", ((Depart*)departures[1]).route.id, @"Wrong route id");
    XCTAssertEqualObjects(@"0064", ((Depart*)departures[2]).route.id, @"Wrong route id");
    XCTAssertEqualObjects(@"0064", ((Depart*)departures[3]).route.id, @"Wrong route id");
}

@end
