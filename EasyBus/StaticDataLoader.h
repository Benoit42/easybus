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
#import "RoutesStopsCsvReader.h"

//Déclaration des notifications
FOUNDATION_EXPORT NSString *const dataLoadingProgress;
FOUNDATION_EXPORT NSString *const dataLoadingFinished;

@interface StaticDataLoader : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) StaticDataManager *staticDataManager;
@property(nonatomic) RoutesCsvReader* routesCsvReader;
@property(nonatomic) StopsCsvReader* stopsCsvReader;
@property(nonatomic) TripsCsvReader* tripsCsvReader;
@property(nonatomic) StopTimesCsvReader* stopTimesCsvReader;
@property(nonatomic) RoutesStopsCsvReader* routesStopsCsvReader;

- (void)loadDataFromWeb:(NSURL*)directory;
- (void)loadDataFromLocalFiles:(NSURL*)directory;

//Privé
- (void) matchTrips:(NSArray*)trips andStops:(NSArray*)stops;
- (void) matchRoutesAndStops:(NSArray*)routeStops;

@end
