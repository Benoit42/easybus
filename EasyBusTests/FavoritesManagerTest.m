//
//  FavoritesManagerTest.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <XCTest/XCTest.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "GroupManager.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"
#import "NSManagedObjectContext+Favorite.h"
#import "NSManagedObjectContext+Network.h"

@interface FavoritesManagerTest : XCTestCase

@property(nonatomic) NSManagedObjectContext* managedObjectContext;
@property(nonatomic) RoutesCsvReader* routesCsvReader;
@property(nonatomic) StopsCsvReader* stopsCsvReader;
@property(nonatomic) GroupManager* groupManager;

@end

@implementation FavoritesManagerTest
objection_requires(@"managedObjectContext", @"groupManager", @"routesCsvReader", @"stopsCsvReader")

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
    NSURL* routesUrl = [[NSBundle mainBundle] URLForResource:@"routes_light" withExtension:@"txt"];
    [self.routesCsvReader loadData:routesUrl];
    NSURL* stopsUrl = [[NSBundle mainBundle] URLForResource:@"stops_light" withExtension:@"txt"];
    [self.stopsCsvReader loadData:stopsUrl];

    //Ajout du jeu de tests
    Route* route64 = [self.managedObjectContext routeForId:@"0064"];
    Route* route164 = [self.managedObjectContext routeForId:@"0164"];
    Stop* stopTimo = [self.managedObjectContext stopForId:@"4001"];
    Stop* stopRepu = [self.managedObjectContext stopForId:@"1167"];
    XCTAssertEqual([[self.managedObjectContext favorites] count], 0U, @"Wrong number of favorites");
    [self.managedObjectContext addFavorite:route64 stop:stopTimo direction:@"0"];
    [self.managedObjectContext addFavorite:route64 stop:stopRepu direction:@"1"];
    [self.managedObjectContext addFavorite:route164 stop:stopTimo direction:@"0"];
    [self.managedObjectContext addFavorite:route164 stop:stopRepu direction:@"1"];
}

- (void)tearDown
{
    [super tearDown];
}

//Test des favoris
- (void)testFavorites {
    //Lecture des favoris
    NSArray* favorites = [self.managedObjectContext favorites];
    
    //Vérifications
    XCTAssertEqual([favorites count], 4U, @"Wrong number of favorites");
}

//Test de l'ajout
- (void)testAddFavorite {
    //Préparation des données
    NSUInteger favCount = [[self.managedObjectContext favorites] count];
    NSUInteger groupCount = [[self.groupManager groups] count];

    //Ajout d'un favori
    Route* route = [self.managedObjectContext routeForId:@"0200"];
    Stop* stop = [self.managedObjectContext stopForId:@"4001"];
    [self.managedObjectContext addFavorite:route stop:stop direction:@"0"];

    //Vérifications
    XCTAssertEqual([[self.managedObjectContext favorites] count], favCount+1, @"Wrong number of favorites");
    XCTAssertEqual([[self.groupManager groups] count], groupCount+1, @"Wrong number of groups");
}

//Test de l'ajout d'un doublon
- (void)testAddFavoriteDoublon {
    //Préparation des données
    NSUInteger favCount = [[self.managedObjectContext favorites] count];
    Route* route64 = [self.managedObjectContext routeForId:@"0064"];
    Stop* stopTimo = [self.managedObjectContext stopForId:@"4001"];
    
    //Ajout d'un favori
    [self.managedObjectContext addFavorite:route64 stop:stopTimo direction:@"0"];

    //Vérifications
    XCTAssertEqual([[self.managedObjectContext favorites] count], favCount, @"Wrong number of favorites");
}

//Test de la suppression
- (void)testRemoveFavorite {
    //Récupération d'un favori
    NSUInteger favCount = [[self.managedObjectContext favorites] count];
    Favorite* favorite = [[self.managedObjectContext favorites] lastObject];

    //Suppression du favori
    [self.managedObjectContext removeFavorite:favorite];
    
    //Vérifications
    XCTAssertEqual([[self.managedObjectContext favorites] count], favCount-1, @"Wrong number of favorites");
}

@end
