//
//  StopTime.h
//  EasyBus
//
//  Created by Benoit on 02/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StopTime : NSObject

@property (nonatomic, retain) NSString * tripId;
@property (nonatomic, retain) NSString * stopId;
@property (nonatomic, retain) NSNumber * stopSequence;

@end
