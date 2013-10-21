//
//  NSURLProtocolStubTests.m
//  EPGWithAvalaibleContent
//
//  Created by Yannick LE SAOUT on 08/07/13.
//  Copyright (c) 2013 Orange. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"

@interface AsyncTestCaseTest : AsyncTestCase

@end

@implementation AsyncTestCaseTest

// Test notification waiting
- (void)testWaitForNotification {
    [self runTestWithBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"testNotification" object:self];
        }
        waitingForNotifications:@[@"testNotification"]
        withTimeout:5
    ];
}

// Test timeout (no notification)
- (void)testTimeout {
    @try {
        [self runTestWithBlock:^{}
            waitingForNotifications:@[@"dummy"]
            withTimeout:1
         ];
        
        XCTFail(@"Should have failed");
    }
    @catch (NSException *exception) {
        XCTAssertEqualObjects([exception name], @"timeout", @"Wrong exception");
    }
}

@end
