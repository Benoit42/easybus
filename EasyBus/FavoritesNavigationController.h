//
//  FavoritesNavigationControler.h
//  EasyBus
//
//  Created by Benoit on 29/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StaticDataManager.h"
#import "FavoritesManager.h"
#import "GroupManager.h"
#import "RoutesCsvReader.h"

@interface FavoritesNavigationController : UINavigationController

@property(retain, nonatomic) StaticDataManager* staticDataManager;
@property(retain, nonatomic) FavoritesManager* favoritesManager;
@property (nonatomic, retain) GroupManager* groupManager;

@property(retain, nonatomic) Route* _currentFavoriteRoute;
@property(retain, nonatomic) Stop* _currentFavoriteStop;
@property(retain, nonatomic) NSString* _currentFavoriteDirection;

@end
