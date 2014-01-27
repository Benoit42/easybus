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
#import "StaticDataLoader.h"
#import "LocationManager.h"

@interface MainViewController : UIViewController

@property (nonatomic, retain) FavoritesManager *favoritesManager;
@property (nonatomic, retain) DeparturesManager *departuresManager;
@property (nonatomic, retain) StaticDataManager *staticDataManager;
@property (nonatomic, retain) StaticDataLoader *staticDataLoader;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@end
