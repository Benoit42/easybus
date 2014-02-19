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

- (void)setTrips:(NSArray *)trips {
    DeparturesTableViewController* departuresTableViewController = self.viewControllers[0];
    departuresTableViewController.trips = trips;
}

- (void)setTitle:(NSString *)title {
    DeparturesTableViewController* departuresTableViewController = self.viewControllers[0];
    departuresTableViewController.title = title;
}

@end
