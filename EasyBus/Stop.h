//
//  Stop.h
//  EasyBus
//
//  Created by Benoît on 15/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Route, Trip;

@interface Stop : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) id location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *trips;
@property (nonatomic, retain) NSOrderedSet *routesDirectionOne;
@property (nonatomic, retain) NSOrderedSet *routesDirectionZero;
@end

@interface Stop (CoreDataGeneratedAccessors)

- (void)addTripsObject:(Trip *)value;
- (void)removeTripsObject:(Trip *)value;
- (void)addTrips:(NSSet *)values;
- (void)removeTrips:(NSSet *)values;

- (void)insertObject:(Route *)value inRoutesDirectionOneAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRoutesDirectionOneAtIndex:(NSUInteger)idx;
- (void)insertRoutesDirectionOne:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRoutesDirectionOneAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRoutesDirectionOneAtIndex:(NSUInteger)idx withObject:(Route *)value;
- (void)replaceRoutesDirectionOneAtIndexes:(NSIndexSet *)indexes withRoutesDirectionOne:(NSArray *)values;
- (void)addRoutesDirectionOneObject:(Route *)value;
- (void)removeRoutesDirectionOneObject:(Route *)value;
- (void)addRoutesDirectionOne:(NSOrderedSet *)values;
- (void)removeRoutesDirectionOne:(NSOrderedSet *)values;
- (void)insertObject:(Route *)value inRoutesDirectionZeroAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRoutesDirectionZeroAtIndex:(NSUInteger)idx;
- (void)insertRoutesDirectionZero:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRoutesDirectionZeroAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRoutesDirectionZeroAtIndex:(NSUInteger)idx withObject:(Route *)value;
- (void)replaceRoutesDirectionZeroAtIndexes:(NSIndexSet *)indexes withRoutesDirectionZero:(NSArray *)values;
- (void)addRoutesDirectionZeroObject:(Route *)value;
- (void)removeRoutesDirectionZeroObject:(Route *)value;
- (void)addRoutesDirectionZero:(NSOrderedSet *)values;
- (void)removeRoutesDirectionZero:(NSOrderedSet *)values;
@end
