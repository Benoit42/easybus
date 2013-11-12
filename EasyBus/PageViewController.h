//
//  PageViewController.h
//  EasyBus
//
//  Created by Benoit on 26/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoritesManager.h"
#import "GroupManager.h"
#import "DeparturesManager.h"
#import "LocationManager.h"
#import "StaticDataManager.h"
#import "PageViewControllerDatasource.h"

@interface PageViewController : UIPageViewController <UIPageViewControllerDelegate>

@property (nonatomic, retain) FavoritesManager *favoritesManager;
@property (nonatomic, retain) GroupManager *groupManager;
@property (nonatomic, retain) DeparturesManager *departuresManager;
@property (nonatomic, retain) LocationManager *locationManager;
@property (nonatomic, retain) PageViewControllerDatasource *pageDataSource;

@end
