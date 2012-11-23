//
//  FavoritesViewController.h
//  EasyBus
//
//  Created by Benoit on 13/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoritesManager.h"

@interface FavoritesViewController : UITableViewController

@property(strong, nonatomic) FavoritesManager* _favoritesManager;

@end
