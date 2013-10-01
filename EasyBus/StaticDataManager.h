//
//  StaticDataManager.h
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoutesCsvReader.h"
#import "RoutesStopsCsvReader.h"
#import "StopsCsvReader.h"

@interface StaticDataManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic) RoutesCsvReader* routesCsvReader;
@property(nonatomic) RoutesStopsCsvReader* routesStopsCsvReader;
@property(nonatomic) StopsCsvReader* stopsCsvReader;

- (NSArray*) routes;
- (Route*) routeForId:(NSString*)routeId;
- (NSArray*) stopsForRoute:(Route*)route direction:(NSString*)direction;
- (Stop*) stopForId:(NSString*)stopId;
- (void) reloadDatabase;
- (UIImage*) pictoForRouteId:(NSString*)routeId;

@end
