//
//  Group+Additions.m
//  EasyBus
//
//  Created by Benoît on 19/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import "Group+Additions.h"

@implementation Group (Additions)

- (NSString *)description {
    return [NSString stringWithFormat: @"[Group: name=%@", self.name];
}

@end
