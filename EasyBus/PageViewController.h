//
//  PageViewController.h
//  EasyBus
//
//  Created by Benoit on 26/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationManager.h"
#import "PageViewControllerDatasource.h"
#import "DeparturesManager.h"

@interface PageViewController : UIPageViewController <UIPageViewControllerDelegate>

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic) DeparturesManager* departuresManager;

@property (nonatomic, retain) LocationManager *locationManager;
@property (nonatomic, retain) PageViewControllerDatasource *pageDataSource;

@end
