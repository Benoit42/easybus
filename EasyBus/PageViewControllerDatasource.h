//
//  PageViewControlerDatasource.h
//  EasyBus
//
//  Created by Benoit on 18/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeparturesViewController.h"
#import "FavoritesManager.h"

@interface PageViewControllerDatasource : NSObject <UIPageViewControllerDataSource>

@property (nonatomic, retain) FavoritesManager *favoritesManager;

- (DeparturesViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DeparturesViewController *)viewController;

@end
