//
//  Route.h
//  EasyBus
//
//  Created by Benoît on 27/01/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Favorite, Stop;

@interface Route : NSManagedObject

@property (nonatomic, retain) NSString * fromName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * longName;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * toName;
@property (nonatomic, retain) NSSet *favorites;
@property (nonatomic, retain) NSOrderedSet *stopsDirectionOne;
@property (nonatomic, retain) NSOrderedSet *stopsDirectionZero;
@end

@interface Route (CoreDataGeneratedAccessors)

- (void)addFavoritesObject:(Favorite *)value;
- (void)removeFavoritesObject:(Favorite *)value;
- (void)addFavorites:(NSSet *)values;
- (void)removeFavorites:(NSSet *)values;

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
