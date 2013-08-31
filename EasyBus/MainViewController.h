//
//  MainViewController.h
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "LinesViewController.h"
#import "DeparturesViewController.h"
#import "Favorite.h"

@interface MainViewController : UIViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) FavoritesManager *favoritesManager;

@end
