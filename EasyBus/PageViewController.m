//
//  PageViewController.m
//  EasyBus
//
//  Created by Benoit on 26/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "PageViewController.h"
#import "DeparturesViewController.h"
#import "FavoritesManager.h"

@interface PageViewController()

@property(nonatomic) NSMutableArray* _departuresViewControlers;

@end

@implementation PageViewController

@synthesize currentPage, _departuresViewControlers;

//constructeur
-(id)init {
    if ( self = [super init] ) {
        currentPage = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.

    //Set delegate and datasource
    self.delegate = self;
    self.dataSource = self;
    
    // Create a new view controller and pass suitable data
    DeparturesViewController *departuresViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DeparturesViewController"];
    departuresViewController.page = 0;
    [_departuresViewControlers addObject:departuresViewController];

    NSArray *viewControllers = @[departuresViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.view.frame = pageViewRect;
    
    [self didMoveToParentViewController:self];
    
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    //departuresViewController.view.gestureRecognizers = self.gestureRecognizers;
}

#pragma mark - UIPageViewController delegate methods
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    UIViewController *currentViewController = self.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    self.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

#pragma mark - Page View Controller Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [_departuresViewControlers indexOfObject:viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    //get previous view controller (allready instanciated)
    UIViewController* previousViewController = [_departuresViewControlers objectAtIndex:index-1];
    return previousViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    //get current view controller
    NSUInteger index = [self._departuresViewControlers indexOfObject:viewController];
    if (index == NSNotFound) {
        //impossible en principe, c'est une erreur
        return nil;
    }
    
    //get next view controller
    index++;
    UIViewController* nextViewController = [_departuresViewControlers objectAtIndex:index];
    if (nextViewController == nil) {
        nextViewController = [viewController.storyboard instantiateViewControllerWithIdentifier:@"DeparturesViewController"];
        ((DeparturesViewController*)nextViewController).page = index;
        [_departuresViewControlers addObject:nextViewController];
    }
    return nextViewController;
}

/*- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [[[FavoritesManager singleton] groupes] count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return currentPage;
}*/

@end