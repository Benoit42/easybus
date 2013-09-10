//
//  PageViewControlerDatasource.m
//  EasyBus
//
//  Created by Benoit on 18/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "PageViewControllerDatasource.h"

@interface PageViewControllerDatasource()

@property(nonatomic) NSMutableArray* _departuresViewControlers;

@end

@implementation PageViewControllerDatasource

@synthesize _departuresViewControlers, favoritesManager, groupManager, departuresManager, staticDataManager;

-(id)init {
    if ( self = [super init] ) {
        _departuresViewControlers = [NSMutableArray new];
    }
    return self;
}

- (DeparturesViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    // Return the data view controller for the given index.
    int groupesCount = [[groupManager groups] count];
    if (groupesCount == 0 || (index >= groupesCount)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DeparturesViewController* viewController = nil;
    if (index < [[groupManager groups] count]) {
        if (index < [_departuresViewControlers count]) {
            //Le view controler existe déjà
            viewController = [_departuresViewControlers objectAtIndex:index];
        }
        
        if (viewController == nil) {
            //Le view controler n'existe pas encore
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"DeparturesViewController"];
            ((DeparturesViewController*)viewController).page = index;
            ((DeparturesViewController*)viewController).favoritesManager = self.favoritesManager;
            ((DeparturesViewController*)viewController).departuresManager = self.departuresManager;
            ((DeparturesViewController*)viewController).staticDataManager = self.staticDataManager;
            ((DeparturesViewController*)viewController).groupManager = self.groupManager;
            [_departuresViewControlers insertObject:viewController atIndex:index];
        }
    }
    
    return viewController;
}

- (NSUInteger)indexOfViewController:(DeparturesViewController *)viewController
{
    // Return the index of the given data view controller.
    return viewController.page;
}

#pragma mark - Page View Controller Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DeparturesViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DeparturesViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [[groupManager groups] count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    int count = [[groupManager groups] count];
    return count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    if ([pageViewController.viewControllers count] > 0)
        return ((DeparturesViewController*)[pageViewController.viewControllers objectAtIndex:0]).page;
    else
        return 0;
}

@end
