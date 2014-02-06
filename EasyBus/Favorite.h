//
//  Favorite.h
//  EasyBus
//
//  Created by Benoît on 06/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, Route, Stop;

@interface Favorite : NSManagedObject

@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;

@end
