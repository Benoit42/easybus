//
//  Route+Direction.m
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "Stop+Additions.h"

@implementation Stop (Additions)

- (NSString *)description {
    return [NSString stringWithFormat: @"Stop: id=%@ name=%@", self.id, self.name];
}

@end
