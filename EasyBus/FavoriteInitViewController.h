//
//  FavoriteInitViewController.h
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesManager.h"
#import "StaticDataManager.h"

@interface FavoriteInitViewController : UIViewController

@property (nonatomic, retain) StaticDataManager* staticDataManager;
@property (nonatomic, retain) FavoritesManager* favoritesManager;

@end
