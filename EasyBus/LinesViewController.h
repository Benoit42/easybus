//
//  FlipsideViewController.h
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataManager.h"
#import "StaticDataLoader.h"

@interface LinesViewController : UITableViewController

@property(strong, nonatomic) StaticDataManager* staticDataManager;
@property(strong, nonatomic) StaticDataLoader* staticDataLoader;

@end
