//
//  DeparturesManagerTest.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "DeparturesManager.h"
#import "Favorite.h"
#import "NSURLProtocolStub.h"

@interface DeparturesManagerTest : AsyncTestCase

@property(nonatomic) NSManagedObjectContext* managedObjectContext;
@property(nonatomic) DeparturesManager* departuresManager;

@end

@implementation DeparturesManagerTest
objection_requires(@"managedObjectContext", @"departuresManager")
@synthesize managedObjectContext, departuresManager;

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

//Test du cas droit
- (void)testGetDepartures
{
    //Stub de l'url des départs
    [NSURLProtocol registerClass:[NSURLProtocolStub class]];
    [NSURLProtocolStub bindUrl:@"http://data.keolis-rennes.com/xml/?cmd=getbusnextdepartures" toResource:@"getbusnextdepartures.xml"];
    
    //Création des favoris
    Favorite* fav1 = (Favorite *)[NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext];

    //Recherche des départs
    [self runTestWithBlock:^{
        [self.departuresManager refreshDepartures:@[fav1]];
    }
    waitingForNotifications:@[@"departuresUpdateSucceeded"]
               withTimeout:5
     ];
    XCTAssertEqual(7, (int)[[self.departuresManager getDepartures] count], @"Wrong number of departures");
}

@end
