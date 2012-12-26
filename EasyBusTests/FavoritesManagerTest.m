//
//  FavoritesManagerTest.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "FavoritesManager.h"

@interface FavoritesManagerTest : SenTestCase

@property(nonatomic) FavoritesManager* _favoritesManager;

@end

@implementation FavoritesManagerTest

@synthesize _favoritesManager;

- (void)setUp
{
    [super setUp];
    _favoritesManager = [FavoritesManager new];
}

- (void)tearDown
{
    [super tearDown];
}


//Test de l'ajout
- (void)testAddFavorite
{
    //Purge des favoris sauvegardés
    [_favoritesManager removeAllFavorites];
    
    //Création des favoris
    Favorite* fav1 = [[Favorite alloc] initWithName:@"0064" libLigne:@"Rennes-Acigné" arret:@"a1" libArret:@"Clos Courtel" direction:@"0" libDirection:@"Acigné" lat:0.0 lon:0.0];
    Favorite* fav1b = [[Favorite alloc] initWithName:@"0064" libLigne:@"Rennes-Acigné" arret:@"a1" libArret:@"Clos Courtel" direction:@"0" libDirection:@"Acigné" lat:0.0 lon:0.0];
    Favorite* fav2 = [[Favorite alloc] initWithName:@"0064" libLigne:@"Rennes-Acigné" arret:@"a2" libArret:@"Timonière" direction:@"1" libDirection:@"Rennes" lat:0.0 lon:0.0];

    //Ajout d'un favori en doublon
    [_favoritesManager addFavorite:fav1];
    [_favoritesManager addFavorite:fav1b];
    STAssertEquals(1, (int)[[_favoritesManager favorites] count], @"Wrong number of favorites");

    //Ajout d'un second favori
    [_favoritesManager addFavorite:fav2];
    STAssertEquals(2, (int)[[_favoritesManager favorites] count], @"Wrong number of favorites");
}

//Test de la suppression
- (void)testRemoveFavorites
{
    //Purge des favoris sauvegardés
    [_favoritesManager removeAllFavorites];
    
    //Création des favoris
    Favorite* fav1 = [[Favorite alloc] initWithName:@"0064" libLigne:@"Rennes-Acigné" arret:@"a1" libArret:@"Clos Courtel" direction:@"0" libDirection:@"Acigné" lat:0.0 lon:0.0];
    Favorite* fav2 = [[Favorite alloc] initWithName:@"0064" libLigne:@"Rennes-Acigné" arret:@"a2" libArret:@"Timonière" direction:@"1" libDirection:@"Rennes" lat:0.0 lon:0.0];
    Favorite* fav3 = [[Favorite alloc] initWithName:@"bidon" libLigne:@"bidon" arret:@"bidon" libArret:@"bidon" direction:@"bidon" libDirection:@"bidon" lat:0.0 lon:0.0];
    
    //Ajout des favoris
    [_favoritesManager addFavorite:fav1];
    [_favoritesManager addFavorite:fav2];
    STAssertEquals(2, (int)[[_favoritesManager favorites] count], @"Wrong number of favorites");
    
    //Suppression d'un favori inexistant
    [_favoritesManager removeFavorite:fav3];
    STAssertEquals(2, (int)[[_favoritesManager favorites] count], @"Wrong number of favorites");

    //Suppression d'un favori existant
    [_favoritesManager removeFavorite:fav1];
    STAssertEquals(1, (int)[[_favoritesManager favorites] count], @"Wrong number of favorites");
    [_favoritesManager removeFavorite:fav2];
    STAssertEquals(0, (int)[[_favoritesManager favorites] count], @"Wrong number of favorites");
}

//Test des groupes
- (void)testGroupes
{
    //Purge des favoris sauvegardés
    [_favoritesManager removeAllFavorites];
    
    //Création des favoris
    Favorite* fav1_gr1 = [[Favorite alloc] initWithName:@"0064" libLigne:@"Rennes-Acigné" arret:@"a1" libArret:@"Clos Courtel" direction:@"0" libDirection:@"Acigné" lat:0.0 lon:0.0];
    Favorite* fav2_gr1 = [[Favorite alloc] initWithName:@"0164" libLigne:@"Rennes-Acigné" arret:@"a1" libArret:@"Clos Courtel" direction:@"0" libDirection:@"Acigné" lat:0.0 lon:0.0];
    Favorite* fav3_gr2 = [[Favorite alloc] initWithName:@"0064" libLigne:@"Rennes-Acigné" arret:@"a2" libArret:@"Clos Courtel" direction:@"1" libDirection:@"Rennes" lat:0.0 lon:0.0];
    Favorite* fav4_gr2 = [[Favorite alloc] initWithName:@"0164" libLigne:@"Rennes-Acigné" arret:@"a2" libArret:@"Clos Courtel" direction:@"1" libDirection:@"Rennes" lat:0.0 lon:0.0];
    
    //Ajout des favoris
    [_favoritesManager addFavorite:fav1_gr1];
    [_favoritesManager addFavorite:fav2_gr1];
    [_favoritesManager addFavorite:fav3_gr2];
    [_favoritesManager addFavorite:fav4_gr2];

    //Controle des groupes
    STAssertEquals(2, (int)[[_favoritesManager groupes] count], @"Wrong number of favorites");
    Favorite* groupe1 = [[_favoritesManager groupes] objectAtIndex:0];
    STAssertEquals(@"Acigné", [groupe1 libDirection], @"Wrong groupe 1");
    Favorite* groupe2 = [[_favoritesManager groupes] objectAtIndex:1];
    STAssertEquals(@"Rennes", [groupe2 libDirection], @"Wrong groupe 2");

    //Controle des favoris dans les groupes
    NSArray* fav_groupe1 = [_favoritesManager favoritesForGroupe:fav1_gr1];
    STAssertTrue([fav_groupe1 containsObject:fav1_gr1] , @"Missing favorite 1 in groupe 1");
    STAssertTrue([fav_groupe1 containsObject:fav2_gr1] , @"Missing favorite 2 in groupe 1");
    NSArray* fav_groupe2 = [_favoritesManager favoritesForGroupe:fav3_gr2];
    STAssertTrue([fav_groupe2 containsObject:fav3_gr2] , @"Missing favorite 3 in groupe 1");
    STAssertTrue([fav_groupe2 containsObject:fav4_gr2] , @"Missing favorite 4 in groupe 1");
}
@end
