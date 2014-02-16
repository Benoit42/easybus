//
//  PageViewControlerDatasource.m
//  EasyBus
//
//  Created by Benoit on 18/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "PageViewControllerDatasource.h"
#import "NSManagedObjectContext+Group.h"

@interface PageViewControllerDatasource()

@property(nonatomic) NSMutableArray* departuresViewControlers;

@end

@implementation PageViewControllerDatasource
objection_register(PageViewControllerDatasource);
objection_requires(@"managedObjectContext")

#pragma - Constructor & IoC
- (id)init {
    if ( self = [super init] ) {
        self.departuresViewControlers = [NSMutableArray new];
    }
    return self;
}

- (void)awakeFromObjection {
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext);
}

#pragma - Autres

- (void)reset {
        self.departuresViewControlers = [NSMutableArray new];
}

- (DeparturesTableViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    // Create a new view controller and pass suitable data.
    DeparturesTableViewController* viewController = nil;
    if (index < [[self.managedObjectContext groups] count]) {
        if (index < [self.departuresViewControlers count]) {
            //Le view controler existe déjà
            viewController = [self.departuresViewControlers objectAtIndex:index];
        }
        
        if (viewController == nil) {
            //Le view controler n'existe pas encore
            Group* group = [self.managedObjectContext groups][index];
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"DeparturesTableViewController"];
            ((DeparturesTableViewController*)viewController).trips = [group.trips array];
            ((DeparturesTableViewController*)viewController).title = group.name;
            ((DeparturesTableViewController*)viewController).page = index;
            [self.departuresViewControlers insertObject:viewController atIndex:index];
        }
    }
    
    return viewController;
}

- (NSUInteger)indexOfViewController:(DeparturesTableViewController *)viewController
{
    // Return the index of the given data view controller.
    return [self.departuresViewControlers indexOfObject:viewController];
}

#pragma mark - Page View Controller Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DeparturesTableViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(DeparturesTableViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [[self.managedObjectContext groups] count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {

    int count = [[self.managedObjectContext groups] count];
    return count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    if ([pageViewController.viewControllers count] > 0)
        return ((DeparturesTableViewController*)[pageViewController.viewControllers objectAtIndex:0]).page;
    else
        return 0;
}

@end
