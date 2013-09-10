//
//  MainViewController.h
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "LinesViewController.h"
#import "FavoritesManager.h"
#import "GroupManager.h"
#import "DeparturesManager.h"
#import "StaticDataManager.h"
#import "LocationManager.h"

@interface MainViewController : UIViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) FavoritesManager *favoritesManager;
@property (nonatomic, retain) GroupManager *groupManager;
@property (nonatomic, retain) DeparturesManager *departuresManager;
@property (nonatomic, retain) StaticDataManager *staticDataManager;
@property (nonatomic, retain) LocationManager *locationManager;

@end
