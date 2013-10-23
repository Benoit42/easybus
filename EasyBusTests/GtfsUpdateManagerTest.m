//
//  GtfsUpdateManagerTest.m
//  EasyBus
//
//  Created by Benoit on 13/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"
#import <Objection/Objection.h>
#import "GtfsUpdateManager.h"
#import "IoCModule.h"
#import "IoCModuleTest.h"


@interface GtfsUpdateManagerTest : AsyncTestCase

@property(nonatomic) GtfsUpdateManager* gtfsUpdateManager;

@end

@implementation GtfsUpdateManagerTest

objection_requires(@"gtfsUpdateManager")
@synthesize gtfsUpdateManager;

- (void)setUp {
    [super setUp];
    
    //IoC
    JSObjectionModule* iocModule = [[IoCModule alloc] init];
    JSObjectionModule* iocModuleTest = [[IoCModuleTest alloc] init];
    JSObjectionInjector *injector = [JSObjection createInjectorWithModules:iocModule, iocModuleTest, nil];
    [JSObjection setDefaultInjector:injector];
    
    //Inject dependencies
    [[JSObjection defaultInjector] injectDependencies:self];
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testPublishDate {
    [self runTestWithBlock:^{
        [gtfsUpdateManager refreshPublishData];
    }
    waitingForNotifications:@[@"gtfsUpdateSucceeded"]
               withTimeout:500
    ];

    XCTAssertNotNil(gtfsUpdateManager.publishEntry , @"GTFS publish entry should exists");
}

- (void)testDownloadFile {
    [self runTestWithBlock:^{
        [gtfsUpdateManager refreshPublishData];
    }
   waitingForNotifications:@[@"gtfsUpdateSucceeded"]
               withTimeout:5
     ];

    [self runTestWithBlock:^{
        [gtfsUpdateManager downloadFile:gtfsUpdateManager.publishEntry.url
            withSuccessBlock:^(NSString *filePath) {
                XCTAssertNotNil(filePath , @"GTFS file path should not be nil");
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:filePath] , @"GTFS file path should not be nil");
                [self blockTestCompletedWithBlock:nil];
        } andFailureBlock:^(NSError *error) {
            XCTFail(@"Download shouldn't have failed");
            [self blockTestCompletedWithBlock:nil];
        }];
    }];
}

- (void)testUnzipFile {
    NSString* fromPath = [[[NSBundle mainBundle] URLForResource:@"test" withExtension:@"zip"] path];

    [self runTestWithBlock:^{
        [gtfsUpdateManager unzipFile:fromPath
            withSuccessBlock:^(NSString* outputPath) {
                NSString* testFile = [outputPath stringByAppendingPathComponent:@"test.rtf"];
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:testFile], @"Unzipped file %@ should exist", testFile);
                [self blockTestCompletedWithBlock:nil];
            } andFailureBlock:^(NSError *error) {
                XCTFail(@"Unzipping shouldn't have failed");
                [self blockTestCompletedWithBlock:nil];
            }];
    }];
}

@end
