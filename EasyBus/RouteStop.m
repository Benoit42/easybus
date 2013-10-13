//
//  RouteStop.m
//  EasyBus
//
//  Created by Benoit on 05/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "RouteStop.h"

@implementation RouteStop

@synthesize routeId, directionId, stopId, stopSequence;

- (BOOL)isEqual:(RouteStop*)other {
    if (other == self) {
        return YES;
    }
    else if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    else {
        return [self.routeId isEqualToString:other.routeId] && [self.directionId isEqualToString:other.directionId] && [self.stopId isEqualToString:other.stopId] && [self.stopSequence isEqual:other.stopSequence];
    }
}

- (NSUInteger)hash {
    // See http://stackoverflow.com/questions/254281/best-practices-for-overriding-isequal-and-hash/254380#254380
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.routeId hash];
    result = prime * result + [self.directionId hash];
    result = prime * result + [self.stopId hash];
    result = prime * result + [self.stopSequence hash];
    return result;
}

@end
