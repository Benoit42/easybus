//
//  Route.h
//  EasyBus
//
//  Created by Benoit on 06/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StopSequence;

@interface Route : NSManagedObject

@property (nonatomic, retain) NSString * fromName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * longName;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * toName;
@property (nonatomic, retain) NSOrderedSet *stopsSequenceDirectionOne;
@property (nonatomic, retain) NSOrderedSet *stopsSequenceDirectionZero;
@end

@interface Route (CoreDataGeneratedAccessors)

- (void)insertObject:(StopSequence *)value inStopsSequenceDirectionOneAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStopsSequenceDirectionOneAtIndex:(NSUInteger)idx;
- (void)insertStopsSequenceDirectionOne:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeStopsSequenceDirectionOneAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInStopsSequenceDirectionOneAtIndex:(NSUInteger)idx withObject:(StopSequence *)value;
- (void)replaceStopsSequenceDirectionOneAtIndexes:(NSIndexSet *)indexes withStopsSequenceDirectionOne:(NSArray *)values;
- (void)addStopsSequenceDirectionOneObject:(StopSequence *)value;
- (void)removeStopsSequenceDirectionOneObject:(StopSequence *)value;
- (void)addStopsSequenceDirectionOne:(NSOrderedSet *)values;
- (void)removeStopsSequenceDirectionOne:(NSOrderedSet *)values;
- (void)insertObject:(StopSequence *)value inStopsSequenceDirectionZeroAtIndex:(NSUInteger)idx;
- (void)removeObjectFromStopsSequenceDirectionZeroAtIndex:(NSUInteger)idx;
- (void)insertStopsSequenceDirectionZero:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeStopsSequenceDirectionZeroAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInStopsSequenceDirectionZeroAtIndex:(NSUInteger)idx withObject:(StopSequence *)value;
- (void)replaceStopsSequenceDirectionZeroAtIndexes:(NSIndexSet *)indexes withStopsSequenceDirectionZero:(NSArray *)values;
- (void)addStopsSequenceDirectionZeroObject:(StopSequence *)value;
- (void)removeStopsSequenceDirectionZeroObject:(StopSequence *)value;
- (void)addStopsSequenceDirectionZero:(NSOrderedSet *)values;
- (void)removeStopsSequenceDirectionZero:(NSOrderedSet *)values;
@end
