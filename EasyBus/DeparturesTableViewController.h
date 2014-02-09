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

@property(nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic) DeparturesManager* departuresManager;
@property(nonatomic) Group* group;

- (IBAction)refreshAsked:(id)sender;

@end
