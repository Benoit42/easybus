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
@property (nonatomic) NSProgress* progress;

- (void)loadData:(NSURL*)url;
- (void)cleanUp;

@end
