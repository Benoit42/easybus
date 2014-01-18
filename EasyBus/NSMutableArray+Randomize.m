//
//  NSMutableArray+Randomize.m
//  EasyBus
//
//  Created by Benoit on 16/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "NSMutableArray+Randomize.h"

@implementation NSMutableArray (Randomize)

-(void)randomize {
    for (int i = 0; i < self.count; i++) {
        int randomInt1 = arc4random() % self.count;
        int randomInt2 = arc4random() % self.count;
        [self exchangeObjectAtIndex:randomInt1 withObjectAtIndex:randomInt2];
    }
}
@end
