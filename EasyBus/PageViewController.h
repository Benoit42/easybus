//
//  PageViewController.h
//  EasyBus
//
//  Created by Benoit on 26/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupManager.h"
#import "LocationManager.h"
#import "StaticDataManager.h"
#import "PageViewControllerDatasource.h"

@interface PageViewController : UIPageViewController <UIPageViewControllerDelegate>

@property (nonatomic, retain) GroupManager *groupManager;
@property (nonatomic, retain) LocationManager *locationManager;
@property (nonatomic, retain) PageViewControllerDatasource *pageDataSource;

@end
