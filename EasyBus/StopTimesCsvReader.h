//
//  RouteStopsCsvReader.h
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StopTime.h"

@interface StopTimesCsvReader : NSObject

@property(nonatomic, retain) NSMutableArray* stops;

- (void)loadData;
- (void)cleanUp;

@end
