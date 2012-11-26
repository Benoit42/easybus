//
//  DeparturesManagerTest.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "DeparturesManager.h"
#import "Favorite.h"

@interface DeparturesManagerTest : SenTestCase

@property(nonatomic) DeparturesManager* _departuresManager;

@end

@implementation DeparturesManagerTest
@synthesize _departuresManager;

- (void)setUp
{
    [super setUp];
    _departuresManager = [DeparturesManager new];
}

- (void)tearDown
{
    [super tearDown];
}

//Test du cas droit
- (void)testLoadDeparturesFromKeolis
{
    //Création des favoris
    Favorite* fav1 = [[Favorite alloc] initWithName:@"0064" libLigne:@"Rennes-Acigné" arret:@"a1" libArret:@"Clos Courtel" direction:@"0" libDirection:@"Acigné"];
    Favorite* fav2 = [[Favorite alloc] initWithName:@"0064" libLigne:@"Rennes-Acigné" arret:@"a2" libArret:@"Timonière" direction:@"1" libDirection:@"Rennes"];
    NSArray* favorites = [[NSArray alloc] initWithObjects:fav1, fav2, nil];
    
    //Recherche des départs
    [_departuresManager loadDeparturesFromKeolis:favorites];
    STAssertEquals(7, (int)[[_departuresManager getDepartures] count], @"Wrong number of departures");
}

@end