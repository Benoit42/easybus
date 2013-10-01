//
//  FavoritesManager.h
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Favorite+FavoriteWithAdditions.h"

@interface FavoritesManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (NSArray*) favorites;
- (void) addFavorite:(Route*)route stop:(Stop*)stop direction:(NSString*)direction;
- (void) removeFavorite:(Favorite*)favorite;
- (void) moveFavorite:(Favorite*)favorite fromGroup:(Group*)sourceGroup toGroup:(Group*)destinationGroup atIndex:(NSUInteger)index;

@end
