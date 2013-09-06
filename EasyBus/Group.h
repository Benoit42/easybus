//
//  Group.h
//  EasyBus
//
//  Created by Benoit on 04/09/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Favorite;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * terminus;
@property (nonatomic, retain) NSOrderedSet *favorites;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)insertObject:(Favorite *)value inFavoritesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFavoritesAtIndex:(NSUInteger)idx;
- (void)insertFavorites:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFavoritesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFavoritesAtIndex:(NSUInteger)idx withObject:(Favorite *)value;
- (void)replaceFavoritesAtIndexes:(NSIndexSet *)indexes withFavorites:(NSArray *)values;
- (void)addFavoritesObject:(Favorite *)value;
- (void)removeFavoritesObject:(Favorite *)value;
- (void)addFavorites:(NSOrderedSet *)values;
- (void)removeFavorites:(NSOrderedSet *)values;
@end
