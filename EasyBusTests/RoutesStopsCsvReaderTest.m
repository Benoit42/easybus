//
//  RoutesStopsCsvReaderTest.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <SenTestingKit/SenTestingKit.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "RoutesStopsCsvReader.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"

@interface RoutesStopsCsvReaderTest : SenTestCase

@property(nonatomic) RoutesStopsCsvReader* routesStopsCsvReader;
@property(nonatomic) RoutesCsvReader* routesCsvReader;
@property(nonatomic) StopsCsvReader* stopsCsvReader;
@property(nonatomic) NSManagedObjectModel* managedObjectModel;
@property(nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation RoutesStopsCsvReaderTest

objection_requires(@"managedObjectContext", @"managedObjectModel", @"routesStopsCsvReader", @"routesCsvReader", @"stopsCsvReader")
@synthesize managedObjectModel, managedObjectContext, routesStopsCsvReader, routesCsvReader, stopsCsvReader;

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
    [self.routesStopsCsvReader loadData];
}

- (void)tearDown
{
    [super tearDown];
}


//Test des arrêts de la ligne 64
- (void)testLigne64
{
    //Récupération de la route
    Route* route64 = [self routeForId:@"0064"];
    STAssertNotNil(route64 , @"Route with id 0064 shall exists");
    
    //Vérification des arrêts direction 0
    NSOrderedSet* stops0 = [route64 stopsDirectionZero];
    STAssertNotNil(stops0, @"Stops route 64 direction 0 shall exists");
    STAssertEquals([stops0 count], 22U, @"Stops route 64 direction 0 shall be 22");
    Stop* timoniere0 = [stops0 objectAtIndex:0];
    STAssertEqualObjects([timoniere0 name], @"Timonière", @"Last stop of route 64 shall be Timonière");
    Stop* republique0 = [stops0 lastObject];
    STAssertEqualObjects([republique0 name], @"République Pré Botté", @"First stop of route 64 shall be République");

    //Vérification des arrêts direction 1
    NSOrderedSet* stops1 = [route64 stopsDirectionOne];
    STAssertNotNil(stops1, @"Stops route 64 direction 0 shall exists");
    STAssertEquals([stops1 count], 23U, @"Stops route 64 direction 0 shall be 22");
    Stop*  republique1 = [stops1 objectAtIndex:0];
    STAssertEqualObjects([republique1 name], @"République Pré Botté", @"Last stop of route 64 shall be République");
    Stop* timoniere1 = [stops1 lastObject];
    STAssertEqualObjects([timoniere1 name], @"Timonière", @"First stop of route 64 shall be Timonière");
}

- (Route*) routeForId:(NSString*)routeId {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"fetchRouteWithId"
                                                                    substitutionVariables:@{@"id" : routeId}];
    
    NSError *error = nil;
    NSArray* routes = [self.managedObjectContext executeFetchRequest:request error:&error];
    return ([routes count] == 0) ? nil : [routes objectAtIndex:0];
}

@end
