//
//  StopsViewControler.h
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataManager.h"

@interface DirectionViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic) StaticDataManager* staticDataManager;

@end
