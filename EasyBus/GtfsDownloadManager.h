//
//  UpdateManager.h
//  EasyBus
//
//  Created by Benoit on 09/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GtfsPublishDataTmp.h"
#import "StaticDataLoader.h"

@interface GtfsDownloadManager : NSObject

FOUNDATION_EXPORT NSString* const gtfsUpdateStarted;
FOUNDATION_EXPORT NSString* const gtfsUpdateSucceeded;
FOUNDATION_EXPORT NSString* const gtfsUpdateFailed;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(strong, nonatomic) StaticDataLoader* staticDataLoader;
@property(nonatomic, retain) GtfsPublishDataTmp* publishEntry;
@property(nonatomic, retain) NSString* gtfsFilePath;


-(void)checkUpdateWithDate:(NSDate*)date withSuccessBlock:(void(^)(BOOL))success andFailureBlock:(void(^)(NSError* error))failure;
-(void)loadData:(void(^)())success andFailureBlock:(void(^)(NSError* error))failure;

-(void)refreshPublishDataForDate:(NSDate*)date withSuccessBlock:(void(^)())success andFailureBlock:(void(^)(NSError* error))failure;
-(void)downloadFile:(NSURL*)fileUrl withSuccessBlock:(void(^)(NSURL* filePath))success andFailureBlock:(void(^)(NSError* error))failure;
-(void)unzipFile:(NSURL*)zipFileUrl withSuccessBlock:(void(^)(NSURL* outputPath))success andFailureBlock:(void(^)(NSError* error))failure;

@end