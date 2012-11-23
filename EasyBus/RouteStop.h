//
//  MyClass.h
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteStop : NSObject

@property(nonatomic) NSString* _routeId;
@property(nonatomic) NSString* _stopId;
@property(nonatomic) NSString* _directionId;
@property(nonatomic) NSString* _sequence;

- (id)initWithRouteId:(NSString*)routeId_ stopId:(NSString*)stopId_ directionId:(NSString*)directionId_ sequence:(NSString*)sequence_;

@end
