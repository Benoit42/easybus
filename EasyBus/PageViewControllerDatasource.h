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

- (DeparturesNavigationController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (void)reset;

@end
