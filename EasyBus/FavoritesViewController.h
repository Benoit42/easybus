//
//  FavoritesViewController.h
//  EasyBus
//
//  Created by Benoit on 13/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoritesManager.h"
#import "GroupManager.h"

@interface FavoritesViewController : UITableViewController

@property(retain, nonatomic) FavoritesManager* favoritesManager;
@property (nonatomic, retain) GroupManager* groupManager;

@property(retain, nonatomic) NSNumber* editing;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end
