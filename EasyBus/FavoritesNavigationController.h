//
//  FavoritesNavigationControler.h
//  EasyBus
//
//  Created by Benoit on 29/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoutesCsvReader.h"
#import "Favorite.h"

@interface FavoritesNavigationController : UINavigationController

@property(retain, nonatomic) Favorite* _currentFavorite;

@end
