//
//  StaticDataManager.h
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"
#import "Stop.h"
#import "RouteStop.h"

@interface StaticDataManager : NSObject

+ (StaticDataManager*) singleton;
- (NSArray*) routes;
- (Route*) routesForId:(NSString*)routeId;
- (NSArray*) stopsForRouteId:(NSString*)routeId direction:(NSString*)direction;
- (Stop*) stopForId:(NSString*)stopId;

@end
