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

@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithContext:(NSManagedObjectContext*)context andModel:(NSManagedObjectModel*)model;
- (NSArray*) routes;
- (Route*) routeForId:(NSString*)routeId;
- (NSArray*) stopsForRoute:(Route*)route direction:(NSString*)direction;
- (Stop*) stopForId:(NSString*)stopId;
- (void) reloadDatabase;
- (UIImage*) pictoForRouteId:(NSString*)routeId;

@end
