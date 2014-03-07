//
//  Trip.h
//  EasyBus
//
//  Created by Benoît on 07/03/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FavoriteGroup, ProximityGroup, Route, Stop;

@interface Trip : NSManagedObject

@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) FavoriteGroup *favoriteGroup;
@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) ProximityGroup *proximityGroup;

@end
