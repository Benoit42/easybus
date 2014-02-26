//
//  PageViewControlerDatasource.h
//  EasyBus
//
//  Created by Benoit on 18/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeparturesNavigationController.h"

@interface PageViewControllerDatasource : NSObject <UIPageViewControllerDataSource>

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) LocationManager *locationManager;

- (DeparturesNavigationController *)viewControllerForGroup:(Group*)group storyboard:(UIStoryboard *)storyboard;

@end
