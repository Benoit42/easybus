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
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    currentPage = 0;
    _departuresViewControlers = [NSMutableArray new];

    //Set delegate and datasource
    self.delegate = self;
    self.dataSource = self;
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Création de la 1ère vue
    NSArray* favorites = [[FavoritesManager singleton] favorites];
    if ([favorites count] > 0) {
        // Create a new view controller and pass suitable data
        DeparturesViewController *departuresViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DeparturesViewController"];
        departuresViewController.page = 0;
        [_departuresViewControlers addObject:departuresViewController];
        
        NSArray *viewControllers = @[departuresViewController];
        [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    }
    else {
        //ecran de démarrage sans favoris
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NoFavoritesViewController"];
        NSArray *viewControllers = @[viewController];
        [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    }
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
    UIViewController* nextViewController = nil;
    if (index < [_departuresViewControlers count]) {
        nextViewController = [_departuresViewControlers objectAtIndex:index];
    }
    else if (index < [[[FavoritesManager singleton] groupes] count]) {
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
