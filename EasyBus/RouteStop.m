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
    return [self.routeId isEqualToString:other.routeId] && [self.directionId isEqualToString:other.directionId] && [self.stopId isEqualToString:other.stopId] && [self.stopSequence isEqual:other.stopSequence];
}

- (NSUInteger)hash {
    return [[[[self.routeId stringByAppendingString:self.directionId] stringByAppendingString:self.stopId] stringByAppendingString:[self.stopSequence stringValue]] hash] ;
}

@end
