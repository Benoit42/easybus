//
//  NSObject+AsyncPerformBlock.m
//  EPGWithAvalaibleContent
//
//  Created by  on 22/07/13.
//  Copyright (c) 2013 Orange. All rights reserved.
//

#import "NSObject+AsyncPerformBlock.h"

@implementation NSObject (AsyncPerformBlock)

-(void)performBlockOnMainThread:(void(^)(void))block{
    // If you then need to execute something making sure it's on the main thread (updating the UI for example)
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

-(void)performBlockOnMainThread:(void(^)(void))block afterDelay:(NSTimeInterval)delayInSeconds {
    // If you then need to execute something making sure it's on the main thread (updating the UI for example)
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        block();
    });
}

-(void)performBlockInBackground:(void(^)(void))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block();
    });
}

@end
