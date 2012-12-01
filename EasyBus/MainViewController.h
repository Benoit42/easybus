//
//  MainViewController.h
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "LinesViewController.h"
#import "DeparturesViewController.h"
#import "Favorite.h"

@interface MainViewController : UIViewController

@property (strong, nonatomic) UIPageViewController* _pageViewController;
@property (strong, nonatomic) UIViewController* _noFavoritesViewController;
@property (weak, nonatomic) IBOutlet UILabel *_refreshDate;
@property (weak, nonatomic) IBOutlet UIView *_containerView;

@end
