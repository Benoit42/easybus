//
//  ProximityGroup.h
//  EasyBus
//
//  Created by Benoît on 07/03/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Group.h"

@class Trip;

@interface ProximityGroup : Group

@property (nonatomic, retain) NSSet *trips;
@end

@interface ProximityGroup (CoreDataGeneratedAccessors)

- (void)addTripsObject:(Trip *)value;
- (void)removeTripsObject:(Trip *)value;
- (void)addTrips:(NSSet *)values;
- (void)removeTrips:(NSSet *)values;

@end
