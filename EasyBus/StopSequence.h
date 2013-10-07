//
//  StopSequence.h
//  EasyBus
//
//  Created by Benoit on 06/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Route, Stop;

@interface StopSequence : NSManagedObject

@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) Route *routeDirectionZero;
@property (nonatomic, retain) Route *routeDirectionOne;

@end
