//
//  StopsViewControler.h
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeparturesManager.h"
#import "LocationManager.h"

@interface NearStopsViewController : UITableViewController

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) DeparturesManager *departuresManager;
@property (nonatomic, retain) LocationManager *locationManager;

@end
