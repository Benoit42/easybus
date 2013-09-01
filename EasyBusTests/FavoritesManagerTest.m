//
//  FavoritesManagerTest.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FavoritesManager.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"

@interface FavoritesManagerTest : SenTestCase

@property(nonatomic) RoutesCsvReader* _routesCsvReader;
@property(nonatomic) StopsCsvReader* _stopsCsvReader;
@property(nonatomic) FavoritesManager* _favoritesManager;
@property(nonatomic) NSManagedObjectModel* _managedObjectModel;
@property(nonatomic) NSManagedObjectContext* _managedObjectContext;

@end

@implementation FavoritesManagerTest

@synthesize _favoritesManager, _routesCsvReader, _stopsCsvReader, _managedObjectModel, _managedObjectContext;

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
    STAssertEquals(4U, [[_favoritesManager favorites] count], @"Wrong number of favorites");
    STAssertEqualObjects(@"1167", ((Favorite*)[favorites objectAtIndex:0]).stop.id, @"Wrong favorite 0");
}

//Test de l'ajout
- (void)testAddFavorite
{
    //Ajout d'un favori
    Route* route = [self routeForId:@"0200"];
    Stop* stop = [self stopForId:@"4001"];
    [_favoritesManager addFavorite:route stop:stop direction:@"0"];

    //Vérifications
    STAssertEquals(5U, [[_favoritesManager favorites] count], @"Wrong number of favorites");
}

//Test de l'ajout d'un doublon
- (void)testAddFavoriteDoublon
{
    //Préparation des données
    Route* route64 = [self routeForId:@"0064"];
    Stop* stopTimo = [self stopForId:@"4001"];
    
    //Ajout d'un favori
    [_favoritesManager addFavorite:route64 stop:stopTimo direction:@"0"];

    //Vérifications
    STAssertEquals(4U, [[_favoritesManager favorites] count], @"Wrong number of favorites");
}

//Test de la suppression
- (void)testRemoveFavorite
{
    //Récupération d'un favori
    Favorite* favorite = [[_favoritesManager favorites] lastObject];

    //Suppression du favori
    [_favoritesManager removeFavorite:favorite];
    
    //Vérifications
    STAssertEquals(3U, [[_favoritesManager favorites] count], @"Wrong number of favorites");
}

//Test des groupes
- (void)testGroupes
{
    //Controle des groupes
    NSArray* groupes = [_favoritesManager groupes];
    STAssertEquals(2U, [groupes count], @"Wrong number of groups");

    Favorite* groupe1 = [groupes objectAtIndex:0];
    STAssertEqualObjects(@"1167", groupe1.stop.id, @"Wrong group 1");

    Favorite* groupe2 = [groupes objectAtIndex:1];
    STAssertEqualObjects(@"4001", groupe2.stop.id, @"Wrong group 2");
}

//Test de la suppression
- (void)testFavoritesForGroupe
{
    //Controle des groupes
    NSArray* groupes = [_favoritesManager groupes];
    STAssertEquals(2U, [groupes count], @"Wrong number of groups");
    
    //Vérifications du groupe 0
    Favorite* groupe0 = [groupes objectAtIndex:0];
    STAssertEqualObjects(@"1167", groupe0.stop.id, @"Wrong stop id on group 0");
    STAssertEqualObjects(@"Acigné", [groupe0 terminus] , @"Wrong terminus on group 0");

    //Vérifications des favoris du groupe 0
    NSLog(@"stopId : %@, terminus : %@", groupe0.stop.name, groupe0.terminus);
    NSArray* favorites0 = [_favoritesManager favoritesForGroupe:groupe0];
    STAssertEquals(2U, [favorites0 count], @"Wrong number of favorites in group 1");
    Favorite* groupe0Fav0 = [favorites0 objectAtIndex:0];
    STAssertEqualObjects(@"0064", groupe0Fav0.route.id, @"Erreur on favorite in group 0");
    STAssertEqualObjects(@"4001", groupe0Fav0.stop.id, @"Erreur on favorite in group 0");
    STAssertEqualObjects(@"0", groupe0Fav0.direction, @"Erreur on favorite in group 0");

    //Vérifications du groupe 1
    Favorite* groupe1 = [groupes objectAtIndex:1];
    NSLog(@"stopId : %@, terminus : %@", groupe1.stop.name, groupe1.terminus);
    STAssertEqualObjects(@"4001", groupe1.stop.id, @"Wrong stop id on group 1");
    STAssertEqualObjects(@"Rennes", [groupe1 terminus] , @"Wrong terminus on group 1");
    
    //Vérifications des favoris du groupe 1
    NSArray* favorites1 = [_favoritesManager favoritesForGroupe:groupe0];
    STAssertEquals(2U, [favorites1 count], @"Wrong number of favorites in group 1");
    Favorite* groupe1Fav0 = [favorites1 objectAtIndex:0];
    STAssertEqualObjects(@"0064", groupe1Fav0.route.id, @"Erreur on favorite in group 1");
    STAssertEqualObjects(@"4001", groupe1Fav0.stop.id, @"Erreur on favorite in group 1");
    STAssertEqualObjects(@"0", groupe1Fav0.direction, @"Erreur on favorite in group 1");
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

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


@end
