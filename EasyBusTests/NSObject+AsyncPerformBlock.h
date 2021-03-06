//
//  NSObject+AsyncPerformBlock.h
//  EPGWithAvalaibleContent
//
//  Created by  on 22/07/13.
//  Copyright (c) 2013 Orange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AsyncPerformBlock)

- (void)performBlockOnMainThread:(void(^)(void))block;
- (void)performBlockOnMainThread:(void(^)(void))block afterDelay:(NSTimeInterval)delayInSeconds;
- (void)performBlockInBackground:(void(^)(void))block;

@end
