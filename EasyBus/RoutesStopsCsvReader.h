//
//  RouteStopsCsvReader.h
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoutesStopsCsvReader : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)loadData;

@end
