//
//  MainViewController.h
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "LinesViewController.h"
#import "FavoritesManager.h"
#import "DeparturesManager.h"
#import "StaticDataManager.h"

@interface MainViewController : UIViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) FavoritesManager *favoritesManager;
@property (nonatomic, retain) DeparturesManager *departuresManager;
@property (nonatomic, retain) StaticDataManager *staticDataManager;

@end
