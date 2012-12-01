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

    // Get data for favorites
    //NSArray* favorite = [[FavoritesManager singleton] favorites];
    //[[DeparturesManager singleton] refreshDepartures:favorite];
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Création de la 1ère vue
    NSArray* favorites = [[FavoritesManager singleton] favorites];
    if ([favorites count] > 0 ) {
        if ([_departuresViewControlers count] == 0) {
            //Création de la 1ère vue

            // Create first and second view controller and pass suitable data
            DeparturesViewController *departuresViewController0 = [self.storyboard instantiateViewControllerWithIdentifier:@"DeparturesViewController"];
            departuresViewController0.page = 0;
            DeparturesViewController *departuresViewController1 = [self.storyboard instantiateViewControllerWithIdentifier:@"DeparturesViewController"];
            departuresViewController1.page = 1;

            [_departuresViewControlers addObjectsFromArray:@[departuresViewController0, departuresViewController1]];

            [self setViewControllers:@[departuresViewController0] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
        }
        else {
            //Retour sur la 1ère vue
            DeparturesViewController *departuresViewController = [_departuresViewControlers objectAtIndex:0];
            [self setViewControllers:@[departuresViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
        }
    }
    else {
        //ecran de démarrage sans favoris
        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NoFavoritesViewController"];
        [self setViewControllers:@[viewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    }
}

#pragma mark - UIPageViewController delegate methods
//nothing yet...

#pragma mark - Page View Controller Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    //get current view controller index
    NSUInteger index = [_departuresViewControlers indexOfObject:viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    //get previous view controller (allready instanciated)
    UIViewController* previousViewController = [_departuresViewControlers objectAtIndex:index - 1];
    return previousViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    //get current view controller index
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

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [[[FavoritesManager singleton] groupes] count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return currentPage;
}

@end
