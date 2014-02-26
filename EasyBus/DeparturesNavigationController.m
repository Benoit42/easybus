//
//  NearStopsNavigationController.m
//  EasyBus
//
//  Created by Benoit on 07/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "DeparturesNavigationController.h"
#import "DeparturesTableViewController.h"

@implementation DeparturesNavigationController

- (void)setGroup:(Group *)group {
    _group = group;
    DeparturesTableViewController* departuresTableViewController = self.viewControllers[0];
    departuresTableViewController.group = group;
}

@end
