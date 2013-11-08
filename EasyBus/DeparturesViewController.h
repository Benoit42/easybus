//
//  DeparturesViewController.h
//  EasyBus
//
//  Created by Benoit on 11/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoritesManager.h"
#import "GroupManager.h"
#import "DeparturesManager.h"
#import "StaticDataManager.h"
#import "LocationManager.h"

@interface DeparturesViewController : UIViewController

@property(strong, nonatomic) GroupManager* groupManager;
@property(nonatomic) NSInteger page;

@property (weak, nonatomic) IBOutlet UILabel *direction;

@end
