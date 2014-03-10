//
//  NearStopsNavigationController.h
//  EasyBus
//
//  Created by Benoit on 07/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProximityGroup.h"
#import "LocationManager.h"
#import "DeparturesManager.h"

@interface NearStopsNavigationController : UINavigationController

@property(nonatomic) ProximityGroup* group;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) LocationManager *locationManager;
@property (nonatomic) DeparturesManager *departuresManager;

@end
