//
//  Route.h
//  EasyBus
//
//  Created by Benoit on 04/09/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Stop;

@interface Route : NSManagedObject

@property (nonatomic, retain) NSString * fromName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * longName;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * toName;
@property (nonatomic, retain) NSOrderedSet *stopsDirectionOne;
@property (nonatomic, retain) NSOrderedSet *stopsDirectionZero;
@end

@interface Route (CoreDataGeneratedAccessors)

- (void)insertObject:(Stop *)value inStopsDirectionOneAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStopsDirectionOneAtIndex:(NSUInteger)idx;
- (void)insertStopsDirectionOne:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeStopsDirectionOneAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInStopsDirectionOneAtIndex:(NSUInteger)idx withObject:(Stop *)value;
- (void)replaceStopsDirectionOneAtIndexes:(NSIndexSet *)indexes withStopsDirectionOne:(NSArray *)values;
- (void)addStopsDirectionOneObject:(Stop *)value;
- (void)removeStopsDirectionOneObject:(Stop *)value;
- (void)addStopsDirectionOne:(NSOrderedSet *)values;
- (void)removeStopsDirectionOne:(NSOrderedSet *)values;
- (void)insertObject:(Stop *)value inStopsDirectionZeroAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStopsDirectionZeroAtIndex:(NSUInteger)idx;
- (void)insertStopsDirectionZero:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeStopsDirectionZeroAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInStopsDirectionZeroAtIndex:(NSUInteger)idx withObject:(Stop *)value;
- (void)replaceStopsDirectionZeroAtIndexes:(NSIndexSet *)indexes withStopsDirectionZero:(NSArray *)values;
- (void)addStopsDirectionZeroObject:(Stop *)value;
- (void)removeStopsDirectionZeroObject:(Stop *)value;
- (void)addStopsDirectionZero:(NSOrderedSet *)values;
- (void)removeStopsDirectionZero:(NSOrderedSet *)values;
@end
