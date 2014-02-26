//
//  NearStopsNavigationController.h
//  EasyBus
//
//  Created by Benoit on 07/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "LocationManager.h"
#import "DeparturesManager.h"

@interface NearStopsNavigationController : UINavigationController

@property(nonatomic) Group* group;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) LocationManager *locationManager;
@property (nonatomic) DeparturesManager *departuresManager;

@end
