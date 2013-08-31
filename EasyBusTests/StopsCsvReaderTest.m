//
//  Test.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "StopsCsvReader.h"

@interface StopsCsvReaderTest : SenTestCase

@property(nonatomic) StopsCsvReader* _stopsCsvReader;
@property(nonatomic) NSManagedObjectModel* _managedObjectModel;
@property(nonatomic) NSManagedObjectContext* _managedObjectContext;

@end

@implementation StopsCsvReaderTest

@synthesize _stopsCsvReader, _managedObjectModel, _managedObjectContext;

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
    _stopsCsvReader = [[StopsCsvReader alloc] initWithContext:_managedObjectContext];
    
    //Load data
    [_stopsCsvReader loadData];

}

- (void)tearDown
{
    [super tearDown];
}


//Basic test
- (void)testCountStops
{
    NSError *error = nil;
    NSFetchRequest *request = [_managedObjectModel fetchRequestTemplateForName:@"fetchAllStops"];
    NSArray *stops = [_managedObjectContext executeFetchRequest:request error:&error];

    STAssertEquals(1402U, [stops count], @"Wrong number of stops in stops.txt");
}

//Vérification de l'arrêt Timonière
- (void)testStopTimoniere
{
    NSError *error = nil;
    NSFetchRequest *request = [_managedObjectModel fetchRequestFromTemplateWithName:@"fetchStopWithId"
                                                              substitutionVariables:@{@"id" : @"4001"}];
    NSArray* stops = [_managedObjectContext executeFetchRequest:request error:&error];
    STAssertTrue([stops count] > 0 , @"Stop with id 4001 shall exists");
    Stop* timoniere = [stops objectAtIndex:0];

    STAssertEqualObjects(@"4001", timoniere.id, @"Wrong id for route 0064");
    STAssertEqualObjects(@"4001", timoniere.code, @"Wrong short name for route 0064");
    STAssertEqualObjects(@"Timonière", timoniere.name, @"Wrong long name for route 0064");
    STAssertEqualObjects(@"Acigné", timoniere.desc, @"Wrong from name for route 0064");
    STAssertEqualObjects(@"48.13701918", timoniere.latitude, @"Wrong to name for route 0064");
    STAssertEqualObjects(@"-1.52637517", timoniere.longitude, @"Wrong to name for route 0064");
}


@end
