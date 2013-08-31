//
//  RoutesStopsCsvReaderTest.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RoutesStopsCsvReader.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"

@interface RoutesStopsCsvReaderTest : SenTestCase

@property(nonatomic) RoutesStopsCsvReader* _routesStopsCsvReader;
@property(nonatomic) RoutesCsvReader* _routesCsvReader;
@property(nonatomic) StopsCsvReader* _stopsCsvReader;
@property(nonatomic) NSManagedObjectModel* _managedObjectModel;
@property(nonatomic) NSManagedObjectContext* _managedObjectContext;

@end

@implementation RoutesStopsCsvReaderTest

@synthesize _routesStopsCsvReader, _routesCsvReader, _stopsCsvReader, _managedObjectModel, _managedObjectContext;

- (void)setUp
{
    [super setUp];
    //Create managed context
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    STAssertNotNil(_managedObjectModel, @"Can not create managed object model from main bundle");
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    STAssertNotNil(persistentStoreCoordinator, @"Can not create persistent store coordinator");
    
    NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:0];
    STAssertNotNil(store, @"Can not create In-Memory persistent store");
    
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    _managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    //Tested class
    _routesCsvReader = [[RoutesCsvReader alloc] initWithContext:_managedObjectContext];
    _stopsCsvReader = [[StopsCsvReader alloc] initWithContext:_managedObjectContext];
    _routesStopsCsvReader = [[RoutesStopsCsvReader alloc] initWithContext:_managedObjectContext];
    
    //load data
    [_routesCsvReader loadData];
    [_stopsCsvReader loadData];
    [_routesStopsCsvReader loadData];    
}

- (void)tearDown
{
    [super tearDown];
}


//Test des arrêts de la ligne 64
- (void)testLigne64
{
    //Récupération de la route
    Route* route64 = [self routeForId:@"0064"];
    STAssertNotNil(route64 , @"Route with id 0064 shall exists");
    
    //Vérification des arrêts direction 0
    NSOrderedSet* stops0 = [route64 stopsDirectionZero];
    STAssertNotNil(stops0, @"Stops route 64 direction 0 shall exists");
    STAssertEquals(22U, [stops0 count], @"Stops route 64 direction 0 shall be 22");
    Stop* timoniere0 = [stops0 objectAtIndex:0];
    STAssertEqualObjects(@"Timonière", [timoniere0 name], @"Last stop of route 64 shall be Timonière");
    Stop* republique0 = [stops0 lastObject];
    STAssertEqualObjects(@"République Pré Botté", [republique0 name], @"First stop of route 64 shall be République");

    //Vérification des arrêts direction 1
    NSOrderedSet* stops1 = [route64 stopsDirectionOne];
    STAssertNotNil(stops1, @"Stops route 64 direction 0 shall exists");
    STAssertEquals(23U, [stops1 count], @"Stops route 64 direction 0 shall be 22");
    Stop*  republique1 = [stops1 objectAtIndex:0];
    STAssertEqualObjects(@"République Pré Botté", [republique1 name], @"Last stop of route 64 shall be République");
    Stop* timoniere1 = [stops1 lastObject];
    STAssertEqualObjects(@"Timonière", [timoniere1 name], @"First stop of route 64 shall be Timonière");
}

- (Route*) routeForId:(NSString*)routeId {
    NSFetchRequest *request = [_managedObjectModel fetchRequestFromTemplateWithName:@"fetchRouteWithId"
                                                                    substitutionVariables:@{@"id" : routeId}];
    
    NSError *error = nil;
    NSArray* routes = [_managedObjectContext executeFetchRequest:request error:&error];
    return ([routes count] == 0) ? nil : [routes objectAtIndex:0];
}

@end
