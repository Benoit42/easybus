//
//  Trip+Additions.m
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "Trip+Additions.h"
#import "Route+Additions.h"

@implementation Trip (Additions)

- (NSString*)terminus {
    return [self.route terminusForDirection:self.direction];
}

@end
