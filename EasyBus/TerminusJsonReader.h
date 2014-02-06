//
//  RouteStopsCsvReader.h
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TerminusJsonReader : NSObject

@property (nonatomic, strong) NSDictionary* terminus;
@property (nonatomic) NSProgress* progress;

- (void)loadData:(NSURL*)url;
- (void)cleanUp;

@end
