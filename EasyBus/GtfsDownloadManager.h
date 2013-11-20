//
//  UpdateManager.h
//  EasyBus
//
//  Created by Benoit on 09/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedInfoTmp.h"

@interface GtfsDownloadManager : NSObject

-(void)getGtfsDataForDate:(NSDate*)date withSuccessBlock:(void(^)(FeedInfoTmp* newFeedInfo))success andFailureBlock:(void(^)(NSError* error))failure;
-(void)downloadGtfsData:(NSURL*)fileUrl withSuccessBlock:(void(^)(NSURL* outputPath))success andFailureBlock:(void(^)(NSError* error))failure;
- (void)cleanUp;

//Privée
-(void)unzipFile:(NSURL*)zipFileUrl withSuccessBlock:(void(^)(NSURL* outputPath))success andFailureBlock:(void(^)(NSError* error))failure;
@end
