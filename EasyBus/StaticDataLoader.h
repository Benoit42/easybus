//
//  StaticDataManager.h
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StaticDataManager.h"
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"
#import "TripsCsvReader.h"
#import "StopTimesCsvReader.h"

@interface StaticDataLoader : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) StaticDataManager *staticDataManager;
@property(nonatomic) RoutesCsvReader* routesCsvReader;
@property(nonatomic) StopsCsvReader* stopsCsvReader;
@property(nonatomic) TripsCsvReader* tripsCsvReader;
@property(nonatomic) StopTimesCsvReader* stopTimesCsvReader;

- (void) loadStaticData;

@end
