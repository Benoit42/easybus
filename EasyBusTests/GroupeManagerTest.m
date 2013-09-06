//
//  FavoritesManagerTest.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "GroupManager.h"

@interface GroupManagerTest : SenTestCase

@property(nonatomic) GroupManager* groupManager;
@property(nonatomic) NSManagedObjectModel* managedObjectModel;
@property(nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation GroupManagerTest

@synthesize groupManager, managedObjectModel, managedObjectContext;

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
    STAssertNotNil(store, @"Database error - %@ %@", [error description], [error debugDescription]);

    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;

    //Create class to test
    self.groupManager = [[GroupManager alloc] initWithContext:self.managedObjectContext];
}

- (void)tearDown
{
    [super tearDown];
}

//Test des groupes
- (void)testAddGroups
{
    //Ajout du jeu de tests
    [self.groupManager addGroupWithName:@"Groupe 0" andTerminus:@"Terminus 0"];
    [self.groupManager addGroupWithName:@"Groupe 1" andTerminus:@"Terminus 1"];

    //Lecture des groupes
    NSArray* groups = [self.groupManager groups];
    
    //Vérifications
    STAssertEquals(2U, [groups count], @"Wrong number of groups");
}

//Test de la suppression
- (void)testRemovegroup
{
    //Ajout du jeu de tests
    [self.groupManager addGroupWithName:@"Groupe 0" andTerminus:@"Terminus 0"];
    [self.groupManager addGroupWithName:@"Groupe 1" andTerminus:@"Terminus 1"];
    STAssertEquals(2U, [[self.groupManager groups] count], @"Wrong number of groups");
    
    //Récupération d'un groupe
    NSArray* groups = [self.groupManager groups];
    Group* group = [groups objectAtIndex:0];
    
    //Suppression du groupe
    [self.groupManager removeGroup:group];
    
    //Vérifications
    STAssertEquals(1U, [[self.groupManager groups] count], @"Wrong number of groups");
}

@end
