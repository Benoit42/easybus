//
//  DeparturesViewController.h
//  EasyBus
//
//  Created by Benoit on 11/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoritesManager.h"
#import "DeparturesManager.h"

@interface DeparturesViewController : UITableViewController

@property(strong, nonatomic) FavoritesManager* _favoritesManager;
@property(strong, nonatomic) DeparturesManager* _departuresManager;

@end
