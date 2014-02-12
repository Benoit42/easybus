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

@interface GroupManagerTest : XCTestCase

@property(nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation GroupManagerTest
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
    [self.managedObjectContext addGroupWithName:@"Groupe 0" andTerminus:@"Terminus 0"];
    [self.managedObjectContext addGroupWithName:@"Groupe 1" andTerminus:@"Terminus 1"];

    //Lecture des groupes
    NSArray* groups = [self.managedObjectContext groups];
    
    //Vérifications
    XCTAssertEqual([groups count], 2U, @"Wrong number of groups");
}

//Test de la suppression
- (void)testRemovegroup
{
    //Ajout du jeu de tests
    [self.managedObjectContext addGroupWithName:@"Groupe 0" andTerminus:@"Terminus 0"];
    [self.managedObjectContext addGroupWithName:@"Groupe 1" andTerminus:@"Terminus 1"];
    XCTAssertEqual([[self.managedObjectContext groups] count], 2U, @"Wrong number of groups");
    
    //Récupération d'un groupe
    NSArray* groups = [self.managedObjectContext groups];
    Group* group = [groups objectAtIndex:0];
    
    //Suppression du groupe
    [self.managedObjectContext deleteObject:group];
    
    //Vérifications
    XCTAssertEqual([[self.managedObjectContext groups] count], 1U, @"Wrong number of groups");
}

@end
