//
//  StopTimesCsvReader.h
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StopTime.h"

@interface StopTimesCsvReader : NSObject

@property(nonatomic) NSMutableArray* stops;
@property (nonatomic) NSProgress* progress;

- (void)loadData:(NSURL*)url;
- (void)cleanUp;

@end
