//
//  FavoritesViewController.h
//  EasyBus
//
//  Created by Benoit on 13/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoritesManager.h"
#import "StaticDataManager.h"

@interface FavoritesViewController : UITableViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property(retain, nonatomic) StaticDataManager* staticDataManager;
@property(retain, nonatomic) FavoritesManager* favoritesManager;

@end
