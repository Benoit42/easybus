//
//  DeparturesViewController.h
//  EasyBus
//
//  Created by Benoit on 11/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"

@interface DeparturesViewController : UIViewController

@property(nonatomic) NSInteger page;
@property(strong, nonatomic) Group* group;

@property (weak, nonatomic) IBOutlet UILabel *direction;

@end
