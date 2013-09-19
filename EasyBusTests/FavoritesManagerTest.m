//
//  FavoritesManagerTest.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FavoritesManager.h"
#import "GroupManager.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"

@interface FavoritesManagerTest : SenTestCase

@property(nonatomic) RoutesCsvReader* _routesCsvReader;
@property(nonatomic) StopsCsvReader* _stopsCsvReader;
@property(nonatomic) GroupManager* groupManager;
@property(nonatomic) FavoritesManager* _favoritesManager;
@property(nonatomic) NSManagedObjectModel* _managedObjectModel;
@property(nonatomic) NSManagedObjectContext* _managedObjectContext;

@end

@implementation FavoritesManagerTest

@synthesize _favoritesManager, groupManager, _routesCsvReader, _stopsCsvReader, _managedObjectModel, _managedObjectContext;

- (void)setUp
{
    [super setUp];
    
    //Create managed context
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    STAssertNotNil(_managedObjectModel, @"Can not create managed object model from main bundle");
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    STAssertNotNil(persistentStoreCoordinator, @"Can not create persistent store coordinator");
    
    NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:0];
    NSError* error;
    STAssertNotNil(store, @"Database error - %@ %@", [error description], [error debugDescription]);

    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    _managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;

    //Tested class
    _routesCsvReader = [[RoutesCsvReader alloc] initWithContext:_managedObjectContext];
    _stopsCsvReader = [[StopsCsvReader alloc] initWithContext:_managedObjectContext];
    
    //load data
    [_routesCsvReader loadData];
    [_stopsCsvReader loadData];

    //Create class to test
    groupManager = [[GroupManager alloc] initWithContext:_managedObjectContext];
    _favoritesManager = [[FavoritesManager alloc] initWithContext:_managedObjectContext];
    
    //Ajout du jeu de tests
    Route* route64 = [self routeForId:@"0064"];
    Route* route164 = [self routeForId:@"0164"];
    Stop* stopTimo = [self stopForId:@"4001"];
    Stop* stopRepu = [self stopForId:@"1167"];
    [_favoritesManager addFavorite:route64 stop:stopTimo direction:@"0"];
    [_favoritesManager addFavorite:route64 stop:stopRepu direction:@"1"];
    [_favoritesManager addFavorite:route164 stop:stopTimo direction:@"0"];
    [_favoritesManager addFavorite:route164 stop:stopRepu direction:@"1"];
}

- (void)tearDown
{
    [super tearDown];
}

//Test des favoris
- (void)testFavorites
{
    //Lecture des favoris
    NSArray* favorites = [_favoritesManager favorites];
    
    //Vérifications
    STAssertEquals(4U, [favorites count], @"Wrong number of favorites");
}

//Test de l'ajout
- (void)testAddFavorite
{
    //Préparation des données
    NSUInteger favCount = [[_favoritesManager favorites] count];
    NSUInteger groupCount = [[groupManager groups] count];

    //Ajout d'un favori
    Route* route = [self routeForId:@"0200"];
    Stop* stop = [self stopForId:@"4001"];
    [_favoritesManager addFavorite:route stop:stop direction:@"0"];

    //Vérifications
    STAssertEquals(favCount+1, [[_favoritesManager favorites] count], @"Wrong number of favorites");
    STAssertEquals(groupCount+1, [[groupManager groups] count], @"Wrong number of groups");
}

//Test de l'ajout d'un doublon
- (void)testAddFavoriteDoublon
{
    //Préparation des données
    NSUInteger favCount = [[_favoritesManager favorites] count];
    Route* route64 = [self routeForId:@"0064"];
    Stop* stopTimo = [self stopForId:@"4001"];
    
    //Ajout d'un favori
    [_favoritesManager addFavorite:route64 stop:stopTimo direction:@"0"];

    //Vérifications
    STAssertEquals(favCount, [[_favoritesManager favorites] count], @"Wrong number of favorites");
}

//Test de la suppression
- (void)testRemoveFavorite
{
    //Récupération d'un favori
    NSUInteger favCount = [[_favoritesManager favorites] count];
    Favorite* favorite = [[_favoritesManager favorites] lastObject];

    //Suppression du favori
    [_favoritesManager removeFavorite:favorite];
    
    //Vérifications
    STAssertEquals(favCount-1, [[_favoritesManager favorites] count], @"Wrong number of favorites");
}

- (Route*) routeForId:(NSString*)routeId {
    NSFetchRequest *request = [_managedObjectModel fetchRequestFromTemplateWithName:@"fetchRouteWithId"
                                                              substitutionVariables:@{@"id" : routeId}];
    
    NSError *error = nil;
    NSArray* routes = [_managedObjectContext executeFetchRequest:request error:&error];
    return ([routes count] == 0) ? nil : [routes objectAtIndex:0];
}

- (Stop*) stopForId:(NSString*)stopId {
    NSFetchRequest *request = [_managedObjectModel fetchRequestFromTemplateWithName:@"fetchStopWithId"
                                                              substitutionVariables:@{@"id" : stopId}];
    
    NSError *error = nil;
    NSArray* stops = [_managedObjectContext executeFetchRequest:request error:&error];
    return ([stops count] == 0) ? nil : [stops objectAtIndex:0];
}

@end
