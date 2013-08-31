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
#import "RoutesCsvReader.h"

@interface FavoritesNavigationController : UINavigationController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property(retain, nonatomic) StaticDataManager* staticDataManager;
@property(retain, nonatomic) FavoritesManager* favoritesManager;

@property(retain, nonatomic) Route* _currentFavoriteRoute;
@property(retain, nonatomic) Stop* _currentFavoriteStop;
@property(retain, nonatomic) NSString* _currentFavoriteDirection;

@end
