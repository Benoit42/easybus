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

@interface DeparturesViewController : UITableViewController

@property(strong, nonatomic) FavoritesManager* favoritesManager;
@property(strong, nonatomic) GroupManager* groupManager;
@property(strong, nonatomic) DeparturesManager* departuresManager;
@property (nonatomic, retain) StaticDataManager *staticDataManager;
@property (nonatomic, retain) LocationManager *locationManager;

@property(nonatomic) NSInteger page;
@property (weak, nonatomic) IBOutlet UILabel *_direction;
@property (weak, nonatomic) IBOutlet UILabel *_info;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *_activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *_reloadButton;

- (IBAction)_refreshAsked:(UIButton *)sender;

@end
