//
//  FlipsideViewController.h
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataManager.h"

@interface LinesViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic) StaticDataManager* staticDataManager;

@end
