//
//  NearStopsNavigationControllerViewController.h
//  EasyBus
//
//  Created by Benoit on 07/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeparturesTableViewController.h"
#import "Group.h"

@interface DeparturesNavigationController : UINavigationController

@property(nonatomic) Group* group;

@end
