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
#import "RoutesCsvReader.h"

@interface RoutesCsvReaderTest : SenTestCase

@property(nonatomic) RoutesCsvReader* routesCsvReader;
@property(nonatomic) NSManagedObjectModel* managedObjectModel;
@property(nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation RoutesCsvReaderTest

objection_requires(@"managedObjectContext", @"managedObjectModel", @"routesCsvReader")
@synthesize managedObjectModel, managedObjectContext, routesCsvReader;

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
    [self.routesCsvReader loadData];
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
    STAssertEquals(count, 93, @"Wrong number of routes in routes.txt");
}

//Vérification de la ligne 64
- (void)testRoute0064
{
    NSError *error = nil;
    NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"fetchRouteWithId"
                                                                    substitutionVariables:@{@"id" : @"0064"}];
    NSArray* routes = [self.managedObjectContext executeFetchRequest:request error:&error];
    STAssertTrue([routes count] > 0 , @"Route with id 0064 shall exists");
    Route* route64 = [routes objectAtIndex:0];
    
    STAssertEqualObjects(@"0064", route64.id, @"Wrong id for route 0064");
    STAssertEqualObjects(@"64", route64.shortName, @"Wrong short name for route 0064");
    STAssertEqualObjects(@"Rennes (République) <> Acigné", route64.longName, @"Wrong long name for route 0064");
    STAssertEqualObjects(@"Rennes", route64.fromName, @"Wrong from name for route 0064");
    STAssertEqualObjects(@"Acigné", route64.toName, @"Wrong to name for route 0064");
}

@end
