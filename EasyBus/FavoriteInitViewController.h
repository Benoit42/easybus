//
//  FavoriteInitViewController.h
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesManager.h"

@interface FavoriteInitViewController : UIViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) FavoritesManager *favoritesManager;

@end
