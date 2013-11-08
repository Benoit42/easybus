//
//  DepartuesTableViewController.h
//  EasyBus
//
//  Created by Benoit on 06/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesManager.h"
#import "GroupManager.h"
#import "DeparturesManager.h"
#import "StaticDataManager.h"
#import "LocationManager.h"

@interface DeparturesTableViewController : UITableViewController

@property(strong, nonatomic) FavoritesManager* favoritesManager;
@property(strong, nonatomic) GroupManager* groupManager;
@property(strong, nonatomic) DeparturesManager* departuresManager;
@property (nonatomic, retain) StaticDataManager *staticDataManager;

@end
