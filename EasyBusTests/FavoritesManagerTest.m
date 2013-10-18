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
#import "FavoritesManager.h"
#import "GroupManager.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"

@interface FavoritesManagerTest : XCTestCase

@property(nonatomic) NSManagedObjectModel* managedObjectModel;
@property(nonatomic) NSManagedObjectContext* managedObjectContext;
@property(nonatomic) RoutesCsvReader* routesCsvReader;
@property(nonatomic) StopsCsvReader* stopsCsvReader;
@property(nonatomic) GroupManager* groupManager;
@property(nonatomic) FavoritesManager* favoritesManager;

@end

@implementation FavoritesManagerTest

objection_requires(@"managedObjectContext", @"managedObjectModel", @"favoritesManager", @"groupManager", @"routesCsvReader", @"stopsCsvReader")
@synthesize managedObjectContext, managedObjectModel, favoritesManager, groupManager, routesCsvReader, stopsCsvReader;

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
    [self.routesCsvReader loadData];
    [self.stopsCsvReader loadData];

    //Ajout du jeu de tests
    Route* route64 = [self routeForId:@"0064"];
    Route* route164 = [self routeForId:@"0164"];
    Stop* stopTimo = [self stopForId:@"4001"];
    Stop* stopRepu = [self stopForId:@"1167"];
    XCTAssertEqual([[self.favoritesManager favorites] count], 0U, @"Wrong number of favorites");
    [self.favoritesManager addFavorite:route64 stop:stopTimo direction:@"0"];
    [self.favoritesManager addFavorite:route64 stop:stopRepu direction:@"1"];
    [self.favoritesManager addFavorite:route164 stop:stopTimo direction:@"0"];
    [self.favoritesManager addFavorite:route164 stop:stopRepu direction:@"1"];
}

- (void)tearDown
{
    [super tearDown];
}

//Test des favoris
- (void)testFavorites {
    //Lecture des favoris
    NSArray* favorites = [self.favoritesManager favorites];
    
    //Vérifications
    XCTAssertEqual([favorites count], 4U, @"Wrong number of favorites");
}

//Test de l'ajout
- (void)testAddFavorite {
    //Préparation des données
    NSUInteger favCount = [[self.favoritesManager favorites] count];
    NSUInteger groupCount = [[self.groupManager groups] count];

    //Ajout d'un favori
    Route* route = [self routeForId:@"0200"];
    Stop* stop = [self stopForId:@"4001"];
    [self.favoritesManager addFavorite:route stop:stop direction:@"0"];

    //Vérifications
    XCTAssertEqual([[self.favoritesManager favorites] count], favCount+1, @"Wrong number of favorites");
    XCTAssertEqual([[self.groupManager groups] count], groupCount+1, @"Wrong number of groups");
}

//Test de l'ajout d'un doublon
- (void)testAddFavoriteDoublon {
    //Préparation des données
    NSUInteger favCount = [[self.favoritesManager favorites] count];
    Route* route64 = [self routeForId:@"0064"];
    Stop* stopTimo = [self stopForId:@"4001"];
    
    //Ajout d'un favori
    [self.favoritesManager addFavorite:route64 stop:stopTimo direction:@"0"];

    //Vérifications
    XCTAssertEqual([[self.favoritesManager favorites] count], favCount, @"Wrong number of favorites");
}

//Test de la suppression
- (void)testRemoveFavorite {
    //Récupération d'un favori
    NSUInteger favCount = [[self.favoritesManager favorites] count];
    Favorite* favorite = [[self.favoritesManager favorites] lastObject];

    //Suppression du favori
    [self.favoritesManager removeFavorite:favorite];
    
    //Vérifications
    XCTAssertEqual([[self.favoritesManager favorites] count], favCount-1, @"Wrong number of favorites");
}

- (Route*) routeForId:(NSString*)routeId {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"fetchRouteWithId"
                                                              substitutionVariables:@{@"id" : routeId}];
    
    NSError *error = nil;
    NSArray* routes = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    return ([routes count] == 0) ? nil : [routes objectAtIndex:0];
}

- (Stop*) stopForId:(NSString*)stopId {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"fetchStopWithId"
                                                              substitutionVariables:@{@"id" : stopId}];
    
    NSError *error = nil;
    NSArray* stops = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    return ([stops count] == 0) ? nil : [stops objectAtIndex:0];
}

@end
