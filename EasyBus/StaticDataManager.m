//
//  StaticDataManager.m
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "StaticDataManager.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"
#import "RoutesStopsCsvReader.h"

@interface StaticDataManager()

@property(nonatomic) RoutesCsvReader* _routesCsvReader;
@property(nonatomic) RoutesStopsCsvReader* _routesStopsCsvReader;
@property(nonatomic) StopsCsvReader* _stopsCsvReader;

@end

@implementation StaticDataManager

@synthesize _routesCsvReader, _routesStopsCsvReader, _stopsCsvReader;

+ (StaticDataManager*) singleton {
    static StaticDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[StaticDataManager alloc] init];
    });
    return sharedInstance;
    
}

- (id)init {
    if ( self = [super init] ) {
        // init data
        _routesCsvReader = [RoutesCsvReader new];
        _stopsCsvReader = [StopsCsvReader new];
        _routesStopsCsvReader = [RoutesStopsCsvReader new];
    }
    return self;
}

- (NSArray*) routes {
    return _routesCsvReader._routes;
}

- (Route*) routesForId:(NSString*)routeId {
    NSUInteger idx = [_routesCsvReader._routes indexOfObjectPassingTest:
                      ^ BOOL (Route* current, NSUInteger idx, BOOL *stop)
                      {
                          return [current._id isEqualToString:routeId];
                      }];
    
    if (idx != NSNotFound) {
        return [_routesCsvReader._routes objectAtIndex:idx];
    }
    else {
        return nil;
    }
}

// Return the stops for a route and a direction
- (NSArray*) stopsForRouteId:(NSString*)routeId direction:(NSString*)direction {
    return [[_routesStopsCsvReader _routeStops] objectForKey:[NSString stringWithFormat:@"%@-%@", routeId, direction]];
}

- (Stop*) stopForId:(NSString*)stopId {
    return [_stopsCsvReader._stops objectForKey:stopId];
}

@end
