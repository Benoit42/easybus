//
//  PageViewControlerDatasource.h
//  EasyBus
//
//  Created by Benoit on 18/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeparturesTableViewController.h"

@interface PageViewControllerDatasource : NSObject <UIPageViewControllerDataSource>

@property (nonatomic) NSManagedObjectContext *managedObjectContext;

- (DeparturesTableViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (void)reset;

@end
