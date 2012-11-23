//
//  MyClass.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "RouteStop.h"

@implementation RouteStop

@synthesize  _routeId, _stopId, _sequence, _directionId;

- (id)initWithRouteId:(NSString*)routeId_ stopId:(NSString*)stopId_ directionId:(NSString*)directionId_ sequence:(NSString*)sequence_ {
    _routeId = routeId_;
    _stopId = stopId_;
    _sequence = sequence_;
    _directionId = directionId_;
    
    return self;
}

@end
