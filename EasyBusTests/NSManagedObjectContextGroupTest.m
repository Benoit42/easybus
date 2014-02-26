//
//  GroupeManagerTest.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <XCTest/XCTest.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "NSManagedObjectContext+Group.h"

@interface NSManagedObjectContextGroupTest : XCTestCase

@property(nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation NSManagedObjectContextGroupTest
objection_requires(@"managedObjectContext")

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
}

- (void)tearDown
{
    [super tearDown];
}

//Test des groupes
- (void)testAddGroups
{
    //Ajout du jeu de tests
    Group* group1 = [self.managedObjectContext addGroupWithName:@"Groupe 1" isNearStopGroup:NO];
    Group* group0 = [self.managedObjectContext addGroupWithName:@"Groupe 0" isNearStopGroup:NO];
    Group* groupProx = [self.managedObjectContext addGroupWithName:@"Groupe prox" isNearStopGroup:YES];

    //Vérifications
    XCTAssertEqual([[self.managedObjectContext allGroups] count], 3U, @"Wrong number of groups");
    XCTAssertEqual([[self.managedObjectContext favoriteGroups] count], 2U, @"Wrong number of groups");

    XCTAssertEqual([self.managedObjectContext favoriteGroups][0], group0, @"Wrong group");
    XCTAssertEqual([self.managedObjectContext favoriteGroups][1], group1, @"Wrong group");
    XCTAssertEqual([self.managedObjectContext nearStopGroup], groupProx, @"Wrong group");
}

//Test de la suppression
- (void)testRemovegroup
{
    //Ajout du jeu de tests
    [self.managedObjectContext addGroupWithName:@"Groupe 0" isNearStopGroup:NO];
    [self.managedObjectContext addGroupWithName:@"Groupe 1" isNearStopGroup:NO];
    XCTAssertEqual([[self.managedObjectContext allGroups] count], 2U, @"Wrong number of groups");
    
    //Récupération d'un groupe
    Group* group = [[self.managedObjectContext allGroups] objectAtIndex:0];
    
    //Suppression du groupe
    [self.managedObjectContext deleteObject:group];
    
    //Vérifications
    XCTAssertEqual([[self.managedObjectContext allGroups] count], 1U, @"Wrong number of groups");
}

@end
