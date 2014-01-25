//
//  MenuViewController.h
//  EasyBus
//
//  Created by Benoit on 04/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesManager.h"

@interface MenuViewController : UITableViewController

@property(strong, nonatomic) FavoritesManager* favoritesManager;
@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;
@property (weak, nonatomic) IBOutlet UIButton *organizeButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction)favoritesButton:(id)sender;
- (IBAction)linesButton:(id)sender;
- (IBAction)organizeButton:(id)sender;
- (IBAction)creditsButton:(id)sender;

@end
