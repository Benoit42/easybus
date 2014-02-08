//
//  StaticDataLoader.h
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoutesCsvReader.h"
#import "StopsCsvReader.h"
#import "TripsCsvReader.h"
#import "TerminusJsonReader.h"
#import "StopTimesCsvReader.h"
#import "RoutesStopsCsvReader.h"
#import "FeedInfoCsvReader.h"
#import "GtfsDownloadManager.h"

//Déclaration des notifications
FOUNDATION_EXPORT NSString *const dataLoadingStarted;
FOUNDATION_EXPORT NSString *const dataLoadingProgress;
FOUNDATION_EXPORT NSString *const dataLoadingFinished;
FOUNDATION_EXPORT NSString *const dataLoadingFailed;

@interface StaticDataLoader : NSObject

@property(nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic) RoutesCsvReader* routesCsvReader;
@property(nonatomic) StopsCsvReader* stopsCsvReader;
@property(nonatomic) TripsCsvReader* tripsCsvReader;
@property(nonatomic) TerminusJsonReader* terminusJsonReader;
@property(nonatomic) StopTimesCsvReader* stopTimesCsvReader;
@property(nonatomic) RoutesStopsCsvReader* routesStopsCsvReader;
@property(nonatomic) FeedInfoCsvReader* feedInfoCsvReader;
@property(nonatomic) GtfsDownloadManager* gtfsDownloadManager;
@property (nonatomic) NSProgress* progress;

- (void)checkUpdate:(NSDate*)date withSuccessBlock:(void(^)(BOOL updateNeeded, NSString* version))success andFailureBlock:(void(^)(NSError* error))failure;
- (void)loadDataFromWebWithSuccessBlock:(void(^)(void))success andFailureBlock:(void(^)(NSError* error))failure;
- (void)loadDataFromLocalFiles:(NSURL*)directory;

//Privé
- (NSArray*) matchTrips:(NSArray*)trips andStops:(NSArray*)stops;
- (void) linkRoutesAndStops:(NSArray*)routeStops;

@end
