//
//  MainViewController.h
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "LinesViewController.h"
#import "GroupManager.h"
#import "DeparturesManager.h"
#import "StaticDataLoader.h"
#import "LocationManager.h"

@interface MainViewController : UIViewController

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) DeparturesManager *departuresManager;
@property (nonatomic) StaticDataLoader *staticDataLoader;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@end
