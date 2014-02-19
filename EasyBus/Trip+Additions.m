//
//  Trip+Additions.m
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "Trip+Additions.h"
#import "Route+Additions.h"
#import "Stop+Additions.h"

@implementation Trip (Additions)

- (NSString*)terminus {
    return [self.route terminusForDirection:self.direction];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"Trip: Route=%@ Stop=%@ Direction=%@", [self.route description], [self.stop description], self.direction];
}

@end
