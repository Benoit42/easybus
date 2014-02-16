//
//  Group.h
//  EasyBus
//
//  Created by Benoît on 16/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trip;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSOrderedSet *trips;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)insertObject:(Trip *)value inTripsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTripsAtIndex:(NSUInteger)idx;
- (void)insertTrips:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTripsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTripsAtIndex:(NSUInteger)idx withObject:(Trip *)value;
- (void)replaceTripsAtIndexes:(NSIndexSet *)indexes withTrips:(NSArray *)values;
- (void)addTripsObject:(Trip *)value;
- (void)removeTripsObject:(Trip *)value;
- (void)addTrips:(NSOrderedSet *)values;
- (void)removeTrips:(NSOrderedSet *)values;
@end
