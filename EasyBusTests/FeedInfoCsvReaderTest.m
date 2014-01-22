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
#import "FeedInfoCsvReader.h"

@interface FeedInfoCsvReaderTest : XCTestCase

@property(nonatomic) FeedInfoCsvReader* feedInfoCsvReader;
@property(nonatomic) NSManagedObjectModel* managedObjectModel;
@property(nonatomic) NSManagedObjectContext* managedObjectContext;

@end

@implementation FeedInfoCsvReaderTest

objection_requires(@"managedObjectContext", @"managedObjectModel", @"feedInfoCsvReader")

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

- (void)testFeedInfo
{
    //Load data
    NSURL* feedInfoUrl = [[NSBundle mainBundle] URLForResource:@"feed_info" withExtension:@"txt"];
    [self.feedInfoCsvReader loadData:feedInfoUrl];

    NSError *error = nil;
    NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"fetchFeedInfo" substitutionVariables:nil];
    NSArray* feedInfoArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    XCTAssertTrue(feedInfoArray.count > 0 , @"There shall be 1 feedInfo");

    FeedInfo* feedInfo = feedInfoArray[0];
    XCTAssertNil(feedInfo.publishDate, @"Wrong publishDate in feedInfo");
    XCTAssertEqualObjects(feedInfo.startDate.description, @"2013-11-03 23:00:00 +0000", @"Wrong startDate in feedInfo");
    XCTAssertEqualObjects(feedInfo.endDate.description, @"2013-12-21 23:00:00 +0000", @"Wrong endDate in feedInfo");
    XCTAssertEqualObjects(feedInfo.version, @"Horaires d'hiver 2013/2014 - Version 3.0 - Novembre / Décembre", @"Wrong version in feedInfo");
}

@end
