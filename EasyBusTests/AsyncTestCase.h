//
//  IOCAsyncTesCase.h
//  EPGWithAvalaibleContent
//
//  Created by  on 11/07/13.
//  Copyright (c) 2013 Orange. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface AsyncTestCase : XCTestCase

@property (nonatomic, retain) dispatch_semaphore_t semaphore;

- (void)runTestWithBlock:(void (^)(void))block;
- (void)blockTestCompletedWithBlock:(void (^)(void))block;

- (NSNotification*)runTestWithBlock:(void (^)(void))block waitingForNotifications:(NSArray*)notifications withTimeout:(NSUInteger)timeoutInSeconds;

@end
