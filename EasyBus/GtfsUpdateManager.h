//
//  UpdateManager.h
//  EasyBus
//
//  Created by Benoit on 09/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GtfsPublishDataTmp.h"

@interface GtfsUpdateManager : NSObject

FOUNDATION_EXPORT NSString* const gtfsUpdateStarted;
FOUNDATION_EXPORT NSString* const gtfsUpdateSucceeded;
FOUNDATION_EXPORT NSString* const gtfsUpdateFailed;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) GtfsPublishDataTmp* publishEntry;


- (void)loadData;
- (void)cleanUp;

-(void)refreshPublishDataWithSuccessBlock:(void(^)(NSURL* fileUrl))success andFailureBlock:(void(^)(NSError* error))failure;
-(void)downloadFile:(NSURL*)fileUrl withSuccessBlock:(void(^)(NSString* filePath))success andFailureBlock:(void(^)(NSError* error))failure;
-(void)unzipFile:(NSString*)zipFilePath withSuccessBlock:(void(^)(NSString* filePath))success andFailureBlock:(void(^)(NSError* error))failure;

@end
