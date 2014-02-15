//
//  RouteStopsCsvReader.h
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TripItem.h"

@interface TripsCsvReader : NSObject

@property(nonatomic, retain) NSMutableArray* trips;
@property (nonatomic, strong) NSMutableDictionary* terminus;
@property (nonatomic) NSProgress* progress;

- (void)loadData:(NSURL*)url;
- (NSString*)terminusLabelForRouteId:(NSString*)routeId andDirectionId:(NSString*)directionId;
- (void)cleanUp;

@end
