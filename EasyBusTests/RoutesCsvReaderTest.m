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
#import "RoutesCsvReader.h"

@interface RoutesCsvReaderTest : XCTestCase

@property(nonatomic) RoutesCsvReader* routesCsvReader;
@property(nonatomic) NSManagedObjectModel* managedObjectModel;
@property(nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation RoutesCsvReaderTest
objection_requires(@"managedObjectContext", @"managedObjectModel", @"routesCsvReader")

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
    NSURL* routesUrl = [[NSBundle mainBundle] URLForResource:@"routes_light" withExtension:@"txt"];
    [self.routesCsvReader loadData:routesUrl];
}

- (void)tearDown
{
    [super tearDown];
}

//Comptage des occurences
- (void)testCountRoutes {
    NSError *error = nil;
    NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"fetchAllRoutes"];
    NSArray *routes = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    int count = [routes count];
    XCTAssertEqual(count, 3, @"Wrong number of routes");
}

//Vérification de la ligne 64
- (void)testRoute0064
{
    NSError *error = nil;
    NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"fetchRouteWithId"
                                                                    substitutionVariables:@{@"id" : @"0064"}];
    NSArray* routes = [self.managedObjectContext executeFetchRequest:request error:&error];
    XCTAssertTrue([routes count] > 0 , @"Route with id 0064 shall exists");
    Route* route64 = [routes objectAtIndex:0];
    
    XCTAssertEqualObjects(@"0064", route64.id, @"Wrong id for route 0064");
    XCTAssertEqualObjects(@"64", route64.shortName, @"Wrong short name for route 0064");
    XCTAssertEqualObjects(@"Rennes (République) <> Acigné", route64.longName, @"Wrong long name for route 0064");
}

@end
