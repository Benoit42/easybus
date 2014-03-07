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
#import "NSManagedObjectContext+Trip.h"
#import "NSManagedObjectContext+Network.h"
#import "StaticDataLoader.h"

@interface NSManagedObjectContextGroupTest : XCTestCase

@property(nonatomic) NSManagedObjectContext* managedObjectContext;
@property(nonatomic) StaticDataLoader* staticDataLoader;

@end

@implementation NSManagedObjectContextGroupTest
objection_requires(@"managedObjectContext", @"staticDataLoader")

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

    //load data
    //Load data
    [self.staticDataLoader loadDataFromLocalFiles:[[NSBundle mainBundle] bundleURL]];
}

- (void)tearDown
{
    [super tearDown];
}

//Test des groupes
- (void)testAddGroups
{
    //Ajout du jeu de tests
    Group* group1 = [self.managedObjectContext addFavoriteGroupWithName:@"Groupe 1"];
    Group* group0 = [self.managedObjectContext addFavoriteGroupWithName:@"Groupe 0"];
    Group* groupProx = [self.managedObjectContext updateProximityGroupForLocation:nil];

    //Vérifications
    XCTAssertEqual([[self.managedObjectContext allGroups] count], 3U, @"Wrong number of groups");
    XCTAssertEqual([[self.managedObjectContext favoriteGroups] count], 2U, @"Wrong number of groups");

    XCTAssertEqual([self.managedObjectContext favoriteGroups][0], group0, @"Wrong group");
    XCTAssertEqual([self.managedObjectContext favoriteGroups][1], group1, @"Wrong group");
    XCTAssertEqual([self.managedObjectContext proximityGroup], groupProx, @"Wrong group");
}

//Test de la suppression
- (void)testRemoveGroup
{
    //Ajout du jeu de tests
    [self.managedObjectContext addFavoriteGroupWithName:@"Groupe 0"];
    [self.managedObjectContext addFavoriteGroupWithName:@"Groupe 1"];
    XCTAssertEqual([[self.managedObjectContext allGroups] count], 2U, @"Wrong number of groups");
    
    //Récupération d'un groupe
    Group* group = [[self.managedObjectContext allGroups] objectAtIndex:0];
    
    //Suppression du groupe
    [self.managedObjectContext deleteObject:group];
    
    //Vérifications
    XCTAssertEqual([[self.managedObjectContext allGroups] count], 1U, @"Wrong number of groups");
}

//Test du nettoyage du proximity group
- (void)testCleanupProximityGroup {
    //Ajout du jeu de tests
    Route* route64 = [self.managedObjectContext routeForId:@"0064"];
    Route* route164 = [self.managedObjectContext routeForId:@"0164"];
    Stop* stopTimo = [self.managedObjectContext stopForId:@"4001"];
    Trip* trip64 = [self.managedObjectContext addTrip:route64 stop:stopTimo direction:@"0"];
    Trip* trip164 = [self.managedObjectContext addTrip:route164 stop:stopTimo direction:@"0"];

    //Création du groupe de favoris
    FavoriteGroup* favoriteGroup = [self.managedObjectContext addFavoriteGroupWithName:@"Groupe 1"];
    [favoriteGroup addTripsObject:trip64];
    [favoriteGroup addTripsObject:trip164];

    //Création du groupe de proximité à la maison
    CLLocation* maison = [[CLLocation alloc] initWithLatitude:+48.138149 longitude:-1.523640];
    ProximityGroup* proximityGroup = [self.managedObjectContext updateProximityGroupForLocation:maison];
    XCTAssertEqual(favoriteGroup.trips.count, 2U, @"Wrong number of trips in favorite group");
    XCTAssertEqual(proximityGroup.trips.count, 4U, @"Wrong number of proximity group");

    //Déplacement au Clos Courtel
    CLLocation* bureau = [[CLLocation alloc] initWithLatitude:+48.127327 longitude:-1.627679];
    proximityGroup = [self.managedObjectContext updateProximityGroupForLocation:bureau];
    XCTAssertEqual(favoriteGroup.trips.count, 2U, @"Wrong number of trips in favorite group");
    XCTAssertEqual(proximityGroup.trips.count, 17U, @"Wrong number of proximity group");

    //Retour à la maison
    proximityGroup = [self.managedObjectContext updateProximityGroupForLocation:maison];
    XCTAssertEqual(favoriteGroup.trips.count, 2U, @"Wrong number of trips in favorite group");
    XCTAssertEqual(proximityGroup.trips.count, 4U, @"Wrong number of proximity group");
}

@end
