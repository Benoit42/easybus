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
#import "NSURLProtocolStub.h"

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
    
    //Mock network resources
    [NSURLProtocol registerClass:[NSURLProtocolStub class]];
    [NSURLProtocolStub bindUrl:@"http://data.keolis-rennes.com/fileadmin/OpenDataFiles/GTFS/feed" toResource:@"gtfsUpdateFeed.xml"];
    [NSURLProtocolStub configureUrl:@"http://data.keolis-rennes.com/fileadmin/OpenDataFiles/GTFS/feed" withHeaders:@{@"Content-Type": @"application/atom-xml; charset=utf-8"}];
    [NSURLProtocolStub bindUrl:@"http://data.keolis-rennes.com/fileadmin/OpenDataFiles/GTFS/GTFS-20131017.zip" toResource:@"GTFS-20131017.zip"];
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testPublishDate {
    [self runTestWithBlock:^{
        [gtfsUpdateManager refreshPublishDataWithSuccessBlock:^(NSURL *fileUrl) {
            XCTAssertNotNil(gtfsUpdateManager.publishEntry , @"GTFS publish entry should exists");
            [self blockTestCompletedWithBlock:nil];
        } andFailureBlock:^(NSError *error) {
            XCTFail(@"Refreshing publish date shouldn't have failed");
            [self blockTestCompletedWithBlock:nil];
        } ];
    }];
}

- (void)testDownloadGtfsFile {
    NSURL* url = [NSURL URLWithString:@"http://data.keolis-rennes.com/fileadmin/OpenDataFiles/GTFS/GTFS-20131017.zip" relativeToURL:nil];
    [self runTestWithBlock:^{
        [gtfsUpdateManager downloadFile:url
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
    NSString* fromPath = [[[NSBundle mainBundle] URLForResource:@"GTFS-20131017" withExtension:@"zip"] path];

    [self runTestWithBlock:^{
        [gtfsUpdateManager unzipFile:fromPath
            withSuccessBlock:^(NSString* outputPath) {
                NSString* testFile = [outputPath stringByAppendingPathComponent:@"routes.txt"];
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:testFile], @"Unzipped file %@ should exist", testFile);
                testFile = [outputPath stringByAppendingPathComponent:@"stops.txt"];
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:testFile], @"Unzipped file %@ should exist", testFile);
                testFile = [outputPath stringByAppendingPathComponent:@"trips.txt"];
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:testFile], @"Unzipped file %@ should exist", testFile);
                testFile = [outputPath stringByAppendingPathComponent:@"stop_times.txt"];
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:testFile], @"Unzipped file %@ should exist", testFile);
                [self blockTestCompletedWithBlock:nil];
            } andFailureBlock:^(NSError *error) {
                XCTFail(@"Unzipping shouldn't have failed");
                [self blockTestCompletedWithBlock:nil];
            }];
    }];
}

@end
