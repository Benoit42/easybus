//
//  LineReader.h
//  EasyBus
//
//  Created by Benoit on 18/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedInfo.h"

@interface FeedInfoCsvReader : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)loadData:(NSURL*)url;
- (void)cleanUp;

@end