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


-(void)refreshData;

@end
