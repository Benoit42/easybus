//
//  RouteStopsCsvReader.h
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteStop.h"

@interface RoutesStopsCsvReader : NSObject

@property(nonatomic, retain) NSMutableArray* routesStops;
@property (nonatomic) NSProgress* progress;

- (void)loadData:(NSURL*)url;
- (void)cleanUp;

@end
