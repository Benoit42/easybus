//
//  NSManagedObjectContext+EasyBus.h
//  EasyBus
//
//  Created by Benoît on 08/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "Route.h"
#import "Stop.h"
#import "FeedInfo.h"

@interface NSManagedObjectContext (EasyBus)

- (FeedInfo*) feedInfo;

- (NSArray*) routes;
- (NSArray*) sortedRoutes;
- (Route*) routeForId:(NSString*)routeId;

- (NSArray*) stops;
- (Stop*) stopForId:(NSString*)stopId;
- (NSArray*) stopsForRoute:(Route*)route direction:(NSString*)direction;
- (NSArray*) stopsSortedByDistanceFrom:(CLLocation*)location;
- (NSArray*) nearestStopsHavingSameNameFrom:(CLLocation*)location;

@end
