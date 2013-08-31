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

- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext;

- (NSArray*) favorites;
- (NSArray*) groupes;
- (NSArray*) favoritesForGroupe:(Favorite*)groupe;
- (void) addFavorite:(Route*)route stop:(Stop*)stop direction:(NSString*)direction;
- (void) removeFavorite:(Favorite*)favorite;

@end
