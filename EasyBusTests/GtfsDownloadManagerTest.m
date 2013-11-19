//
//  GtfsDownloadManagerTest.m
//  EasyBus
//
//  Created by Benoit on 13/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"
#import <Objection/Objection.h>
#import "GtfsDownloadManager.h"
#import "FeedInfo.h"
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "NSURLProtocolStub.h"

@interface GtfsDownloadManagerTest : AsyncTestCase

@property(nonatomic) NSManagedObjectContext* managedObjectContext;
@property(nonatomic) GtfsDownloadManager* gtfsDownloadManager;
@property(nonatomic) NSDateFormatter* dateFormatter;

@end

@implementation GtfsDownloadManagerTest

objection_requires(@"managedObjectContext", @"gtfsDownloadManager")
@synthesize gtfsDownloadManager;

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

    //Date formater
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"dd/MM/yyyy"];
}

- (void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testCheckUpdateNeeded {
    NSDate* date = [self.dateFormatter dateFromString:@"25/06/2013"];
    
    [self runTestWithBlock:^{
        [self.gtfsDownloadManager checkUpdateWithDate:date withSuccessBlock:^(BOOL updateNeeded) {
            XCTAssertTrue(updateNeeded , @"updateNeeded should be true");
            [self blockTestCompletedWithBlock:nil];
        } andFailureBlock:^(NSError *error) {
            XCTFail(@"Checking update shouldn't have failed : %@", [error debugDescription]);
            [self blockTestCompletedWithBlock:nil];
        }];
    }];
}

- (void)testCheckNoUpdateFuture {
    NSDate* date = [self.dateFormatter dateFromString:@"25/05/2013"];
    
    [self runTestWithBlock:^{
        [self.gtfsDownloadManager checkUpdateWithDate:date withSuccessBlock:^(BOOL updateNeeded) {
            XCTAssertFalse(updateNeeded , @"updateNeeded should be false");
            [self blockTestCompletedWithBlock:nil];
        } andFailureBlock:^(NSError *error) {
            XCTFail(@"Checking update shouldn't have failed : %@", [error debugDescription]);
            [self blockTestCompletedWithBlock:nil];
        }];
    }];
}

- (void)testCheckNoUpdatePast {
    NSDate* date = [self.dateFormatter dateFromString:@"25/08/2013"];
    
    [self runTestWithBlock:^{
        [self.gtfsDownloadManager checkUpdateWithDate:date withSuccessBlock:^(BOOL updateNeeded) {
            XCTAssertFalse(updateNeeded , @"updateNeeded should be false");
            [self blockTestCompletedWithBlock:nil];
        } andFailureBlock:^(NSError *error) {
            XCTFail(@"Checking update shouldn't have failed : %@", [error debugDescription]);
            [self blockTestCompletedWithBlock:nil];
        }];
    }];
}

- (void)testCheckUpdateWithJsonError {
    [NSURLProtocolStub bindUrl:@"http://data.keolis-rennes.com/fileadmin/OpenDataFiles/GTFS/feed" toResource:@"gtfsUpdateFeedError.xml"];
    NSDate* date = [self.dateFormatter dateFromString:@"25/06/2013"];

    [self runTestWithBlock:^{
        [self.gtfsDownloadManager checkUpdateWithDate:date withSuccessBlock:^(BOOL updateNeeded) {
            XCTAssertFalse(updateNeeded , @"updateNeeded should be false");
            [self blockTestCompletedWithBlock:nil];
        } andFailureBlock:^(NSError *error) {
            XCTFail(@"Checking update shouldn't have failed : %@", [error debugDescription]);
            [self blockTestCompletedWithBlock:nil];
        }];
    }];
}

- (void)testRefreshPublishData {
    NSDate* date = [self.dateFormatter dateFromString:@"15/06/2013"];
    
    [self runTestWithBlock:^{
        [self.gtfsDownloadManager refreshPublishDataForDate:date
                                           withSuccessBlock:^(FeedInfoTmp *newFeedInfo) {
                                               XCTAssertNotNil(newFeedInfo.url , @"newFeedInfo.url shoul not be nil");
                                               BOOL sameDay = [self isSameDayWithDate1:date date2:newFeedInfo.publishDate];
                                               XCTAssertTrue(sameDay, @"GTFS publish entry date should be 15/06/2013");
                                               [self blockTestCompletedWithBlock:nil];
        }
                                            andFailureBlock:^(NSError *error) {
                                                XCTFail(@"Refreshing publish date shouldn't have failed : %@", [error debugDescription]);
                                                [self blockTestCompletedWithBlock:nil];
        }];
    }];
}

- (void)testDownloadFile {
    //Remark : NSURLSessionDownloadTask can't be stubbed with custom NSURLProtocol
    NSURL* toDownload = [NSURL URLWithString:@"http://phs.googlecode.com/files/Download%20File%20Test.zip" relativeToURL:nil];
    [self runTestWithBlock:^{
        [self.gtfsDownloadManager downloadFile:toDownload
            withSuccessBlock:^(NSURL *fileUrl) {
                XCTAssertNotNil(fileUrl , @"Downloaded file path should not be nil");
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]] , @"Downloaded file should exist");
                [self blockTestCompletedWithBlock:nil];
        } andFailureBlock:^(NSError *error) {
            XCTFail(@"Download shouldn't have failed : %@", [error debugDescription]);
            [self blockTestCompletedWithBlock:nil];
        }];
    }];
}

- (void)testUnzipFile {
    NSURL* fromUrl = [[NSBundle mainBundle] URLForResource:@"GTFS" withExtension:@"zip"];

    [self runTestWithBlock:^{
        [self.gtfsDownloadManager unzipFile:fromUrl
            withSuccessBlock:^(NSURL* outputDirectory) {
                XCTAssertNotNil(outputDirectory , @"Output directory should not be nil");
                NSString* testFile = [[[NSURL URLWithString:@"routes.txt" relativeToURL:outputDirectory] path] stringByRemovingPercentEncoding];
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:testFile], @"Unzipped file %@ should exist", testFile);
                testFile = [[NSURL URLWithString:@"stops.txt" relativeToURL:outputDirectory] path];
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:testFile], @"Unzipped file %@ should exist", testFile);
                testFile = [[NSURL URLWithString:@"trips.txt" relativeToURL:outputDirectory] path];
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:testFile], @"Unzipped file %@ should exist", testFile);
                testFile = [[NSURL URLWithString:@"stop_times.txt" relativeToURL:outputDirectory] path];
                XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:testFile], @"Unzipped file %@ should exist", testFile);
                [self blockTestCompletedWithBlock:nil];
            } andFailureBlock:^(NSError *error) {
                XCTFail(@"Unzipping shouldn't have failed : %@", [error debugDescription]);
                [self blockTestCompletedWithBlock:nil];
            }];
    }];
}

#pragma mark utilitaires
- (BOOL)isSameDayWithDate1:(NSDate*)date1 date2:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}
@end
