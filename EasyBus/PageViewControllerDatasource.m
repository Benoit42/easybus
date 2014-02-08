//
//  PageViewControlerDatasource.m
//  EasyBus
//
//  Created by Benoit on 18/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "PageViewControllerDatasource.h"

@interface PageViewControllerDatasource()

@property(nonatomic) NSMutableArray* departuresViewControlers;

@end

@implementation PageViewControllerDatasource
objection_register(PageViewControllerDatasource);
objection_requires(@"groupManager")

#pragma - Constructor & IoC
- (id)init {
    if ( self = [super init] ) {
        self.departuresViewControlers = [NSMutableArray new];
    }
    return self;
}

- (void)awakeFromObjection {
    //Pré-conditions
    NSParameterAssert(self.groupManager != nil);
}

#pragma - Autres

- (void)reset {
        self.departuresViewControlers = [NSMutableArray new];
}

- (DeparturesViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    // Create a new view controller and pass suitable data.
    DeparturesViewController* viewController = nil;
    if (index < [[self.groupManager groups] count]) {
        if (index < [self.departuresViewControlers count]) {
            //Le view controler existe déjà
            viewController = [self.departuresViewControlers objectAtIndex:index];
        }
        
        if (viewController == nil) {
            //Le view controler n'existe pas encore
            Group* group = self.groupManager.groups[index];
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"DeparturesViewController"];
            ((DeparturesViewController*)viewController).group = group;
            ((DeparturesViewController*)viewController).page = index;
            [self.departuresViewControlers insertObject:viewController atIndex:index];
        }
    }
    
    return viewController;
}

- (NSUInteger)indexOfViewController:(DeparturesViewController *)viewController
{
    // Return the index of the given data view controller.
    return [self.departuresViewControlers indexOfObject:viewController];
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
    if (index == [[self.groupManager groups] count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {

    int count = [[self.groupManager groups] count];
    return count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    if ([pageViewController.viewControllers count] > 0)
        return ((DeparturesViewController*)[pageViewController.viewControllers objectAtIndex:0]).page;
    else
        return 0;
}

@end
