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

@interface StaticDataLoader : NSObject

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property(nonatomic) RoutesCsvReader* routesCsvReader;
@property(nonatomic) RoutesStopsCsvReader* routesStopsCsvReader;
@property(nonatomic) StopsCsvReader* stopsCsvReader;

- (void) loadData;

@end
