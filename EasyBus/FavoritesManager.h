//
//  FavoritesManager.h
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Favorite.h"

@interface FavoritesManager : NSObject

+ (FavoritesManager*) singleton;
- (NSArray*) favorites;
- (NSArray*) groupes;
- (NSArray*) favoritesForGroupe:(Favorite*)groupe;
- (void) addFavorite:(Favorite*)favorite;
- (void) removeFavorite:(Favorite*)favorite;
- (void) removeAllFavorites;
- (void) loadFavoritesFromDisk;
- (void) saveFavoritesToDisk;

@end
