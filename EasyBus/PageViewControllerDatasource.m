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
@synthesize departuresViewControlers, groupManager;

-(id)init {
    if ( self = [super init] ) {
        self.departuresViewControlers = [NSMutableArray new];
    }
    return self;
}

- (DeparturesViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    //Pré-conditions
    NSAssert(self.groupManager != nil, @"groupManager should not be nil");
    NSAssert(self.groupManager.groups.count > 0, @"There should be almost 1 group");
    
    // Create a new view controller and pass suitable data.
    DeparturesViewController* viewController = nil;
    if (index < [[groupManager groups] count]) {
        if (index < [self.departuresViewControlers count]) {
            //Le view controler existe déjà
            viewController = [self.departuresViewControlers objectAtIndex:index];
        }
        
        if (viewController == nil) {
            //Le view controler n'existe pas encore
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"DeparturesViewController"];
            ((DeparturesViewController*)viewController).page = index;
            [self.departuresViewControlers insertObject:viewController atIndex:index];
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
    //Pré-conditions
    NSAssert(self.groupManager != nil, @"groupManager should not be nil");
    
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
    //Pré-conditions
    NSAssert(self.groupManager != nil, @"groupManager should not be nil");
    
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
