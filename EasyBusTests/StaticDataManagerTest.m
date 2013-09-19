//
//  StaticDataManagerTest.m
//  EasyBus
//
//  Created by Benoit on 23/06/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "StaticDataManager.h"

@interface StaticDataManagerTest : SenTestCase

@property(nonatomic) NSManagedObjectModel* managedObjectModel;
@property(nonatomic) NSManagedObjectContext* managedObjectContext;

@property(nonatomic) StaticDataManager* staticDataManager;

@end

@implementation StaticDataManagerTest

@synthesize managedObjectModel, managedObjectContext, staticDataManager;

- (void)setUp
{
    [super setUp];
    
    //Create managed context
    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    STAssertNotNil(self.managedObjectModel, @"Can not create managed object model from main bundle");
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    STAssertNotNil(persistentStoreCoordinator, @"Can not create persistent store coordinator");
    
    NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:0];
    NSError* error;
    STAssertNotNil(store, @"Can not create persistent store");
    if (!store) {
        //Log
        STFail([NSString stringWithFormat:@"Database error - %@ %@", [error description], [error debugDescription]]);
    }
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    
    //Tested class
    self.staticDataManager = [[StaticDataManager alloc] initWithContext:self.managedObjectContext];
}

- (void)tearDown {
    [super tearDown];
}

//Vérification de la ligne 64
- (void)testRoutes
{
    NSArray* routes = [self.staticDataManager routes];
    STAssertTrue([routes count] > 0 , @"Routes shall exist");

    Route* firstRoute = [routes objectAtIndex:0];
    STAssertEqualObjects(@"0001", firstRoute.id, @"First route shall be 0001");


    Route* lastRoute = [routes lastObject];
    STAssertEqualObjects(@"0805", lastRoute.id, @"First route shall be 0805");
}

@end
