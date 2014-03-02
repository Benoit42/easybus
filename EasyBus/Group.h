//
//  Group.h
//  EasyBus
//
//  Created by Benoît on 28/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trip;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSNumber * isNearStopGroup;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *trips;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addTripsObject:(Trip *)value;
- (void)removeTripsObject:(Trip *)value;
- (void)addTrips:(NSSet *)values;
- (void)removeTrips:(NSSet *)values;

@end
