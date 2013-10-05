//
//  RouteStop.h
//  EasyBus
//
//  Created by Benoit on 05/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteStop : NSObject

@property (nonatomic, retain) NSString * routeId;
@property (nonatomic, retain) NSString * directionId;
@property (nonatomic, retain) NSString * stopId;
@property (nonatomic, retain) NSNumber * stopSequence;

@end
