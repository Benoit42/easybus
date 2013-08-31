//
//  StopsViewControler.h
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataManager.h"

@interface StopsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property(retain, nonatomic) StaticDataManager* staticDataManager;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *_saveButton;

@end
