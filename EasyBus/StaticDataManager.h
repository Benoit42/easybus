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

@interface StaticDataManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (NSArray*) routes;
- (Route*) routeForId:(NSString*)routeId;
- (NSArray*) stops;
- (NSArray*) stopsForRoute:(Route*)route direction:(NSString*)direction;
- (Stop*) stopForId:(NSString*)stopId;
- (NSURL*) pictoUrl100ForRouteId:(NSString*)routeId;
- (UIImage*) picto100ForRouteId:(NSString*)routeId;

@end
