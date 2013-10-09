//
//  Group+GroupeWithAdditions.m
//  EasyBus
//
//  Created by Benoit on 08/09/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "Group+GroupeWithAdditions.h"

@implementation Group (GroupeWithAdditions)

//Below methods due to bug in XCode when generating methods
- (void)addFavoritesObject:(Favorite *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.favorites];
    [tempSet addObject:value];
    self.favorites = tempSet;
}

- (void)insertObject:(Favorite *)value inFavoritesAtIndex:(NSUInteger)index {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.favorites];
    [tempSet insertObject:value atIndex:index];
    self.favorites = tempSet;
}

- (void)removeFavoritesObject:(Favorite *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.favorites];
    [tempSet removeObject:value];
    self.favorites = tempSet;
}

@end
