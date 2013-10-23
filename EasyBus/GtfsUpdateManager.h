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

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) GtfsPublishDataTmp* publishEntry;


-(void)refreshPublishData;
-(void)downloadFile:(NSString*)fileUrl withSuccessBlock:(void(^)(NSString* filePath))success andFailureBlock:(void(^)(NSError* error))failure;
-(void)unzipFile:(NSString*)zipFilePath withSuccessBlock:(void(^)(NSString* filePath))success andFailureBlock:(void(^)(NSError* error))failure;

@end
