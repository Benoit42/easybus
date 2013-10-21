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
    block = [block copy];
    
    [self performSelectorOnMainThread:@selector(fireBlockOnMainThread:) withObject:block waitUntilDone:FALSE];
}

-(void)fireBlockOnMainThread:(void(^)(void))block{
    block();
}

@end
