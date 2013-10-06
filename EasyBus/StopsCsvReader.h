//
//  RoutesStopsCsvReader.h
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stop.h"

@interface StopsCsvReader : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)loadData;
- (void)cleanUp;

@end
