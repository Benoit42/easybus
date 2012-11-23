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

@property (weak, nonatomic) IBOutlet UILabel *_refreshDate;
@property (retain, nonatomic) DeparturesViewController* _dvc;

@end
