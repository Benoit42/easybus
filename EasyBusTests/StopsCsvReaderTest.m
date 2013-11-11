//
//  Test.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <XCTest/XCTest.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "StopsCsvReader.h"

@interface StopsCsvReaderTest : XCTestCase

@property(nonatomic) StopsCsvReader* stopsCsvReader;
@property(nonatomic) NSManagedObjectModel* managedObjectModel;
@property(nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation StopsCsvReaderTest

objection_requires(@"managedObjectContext", @"managedObjectModel", @"stopsCsvReader")
@synthesize managedObjectModel, managedObjectContext, stopsCsvReader;

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
    
    //Load data
    NSURL* stopsUrl = [[NSBundle mainBundle] URLForResource:@"stops" withExtension:@"txt"];
    [self.stopsCsvReader loadData:stopsUrl];
}

- (void)tearDown
{
    [super tearDown];
}


//Basic test
- (void)testCountStops
{
    NSError *error = nil;
    NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"fetchAllStops"];
    NSArray *stops = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }

    XCTAssertEqual([stops count], 1409U, @"Wrong number of stops in stops.txt");
}

//Vérification de l'arrêt Timonière
- (void)testStopTimoniere
{
    NSError *error = nil;
    NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"fetchStopWithId"
                                                              substitutionVariables:@{@"id" : @"4001"}];
    NSArray* stops = [self.managedObjectContext executeFetchRequest:request error:&error];
    XCTAssertTrue([stops count] > 0 , @"Stop with id 4001 shall exists");
    Stop* timoniere = [stops objectAtIndex:0];

    XCTAssertEqualObjects(timoniere.id, @"4001", @"Wrong id for route 0064");
    XCTAssertEqualObjects(timoniere.code, @"4001", @"Wrong short name for route 0064");
    XCTAssertEqualObjects(timoniere.name, @"Timonière", @"Wrong long name for route 0064");
    XCTAssertEqualObjects(timoniere.desc, @"Acigné", @"Wrong from name for route 0064");
    XCTAssertEqual(timoniere.location.coordinate.latitude, 48.13701918, @"Wrong to name for route 0064");
    XCTAssertEqual(timoniere.location.coordinate.longitude, -1.52637517, @"Wrong to name for route 0064");
}


@end
