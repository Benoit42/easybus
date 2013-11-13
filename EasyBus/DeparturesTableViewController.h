//
//  DepartuesTableViewController.h
//  EasyBus
//
//  Created by Benoit on 06/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "DeparturesManager.h"

@interface DeparturesTableViewController : UITableViewController

@property(strong, nonatomic) Group* group;
@property(strong, nonatomic) DeparturesManager* departuresManager;

@end
