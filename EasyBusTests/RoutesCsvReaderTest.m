//
//  Test.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RoutesCsvReader.h"

@interface RoutesCsvReaderTest : SenTestCase

@property(nonatomic) RoutesCsvReader* _routesCsvReader;
@property(nonatomic) NSManagedObjectModel* _managedObjectModel;
@property(nonatomic) NSManagedObjectContext* _managedObjectContext;

@end

@implementation RoutesCsvReaderTest

@synthesize _routesCsvReader, _managedObjectModel, _managedObjectContext;

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
    
    //Create tested class
    _routesCsvReader = [[RoutesCsvReader alloc] initWithContext:_managedObjectContext];
    
    //Load data
    [_routesCsvReader loadData];
}

- (void)tearDown
{
    [super tearDown];
}

//Comptage des occurences
- (void)testCountRoutes {
    NSError *error = nil;
    NSFetchRequest *request = [_managedObjectModel fetchRequestTemplateForName:@"fetchAllRoutes"];
    NSArray *routes = [_managedObjectContext executeFetchRequest:request error:&error];
    
    int count = [routes count];
    STAssertEquals(93, count, @"Wrong number of routes in routes.txt");
}

//Vérification de la ligne 64
- (void)testRoute0064
{
    NSError *error = nil;
    NSFetchRequest *request = [_managedObjectModel fetchRequestFromTemplateWithName:@"fetchRouteWithId"
                                                                    substitutionVariables:@{@"id" : @"0064"}];
    NSArray* routes = [_managedObjectContext executeFetchRequest:request error:&error];
    STAssertTrue([routes count] > 0 , @"Route with id 0064 shall exists");
    Route* route64 = [routes objectAtIndex:0];
    
    STAssertEqualObjects(@"0064", route64.id, @"Wrong id for route 0064");
    STAssertEqualObjects(@"64", route64.shortName, @"Wrong short name for route 0064");
    STAssertEqualObjects(@"Rennes (République) <> Acigné", route64.longName, @"Wrong long name for route 0064");
    STAssertEqualObjects(@"Rennes", route64.fromName, @"Wrong from name for route 0064");
    STAssertEqualObjects(@"Acigné", route64.toName, @"Wrong to name for route 0064");
}

@end
