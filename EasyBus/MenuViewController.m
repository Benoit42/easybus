//
//  MenuViewController.m
//  EasyBus
//
//  Created by Benoit on 04/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "MenuViewController.h"
#import "RevealViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController {
    UIViewController* departuresPageViewController;
    UIViewController* favoritesNavigationController;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    departuresPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    favoritesNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritesNavigationController"];
}

- (IBAction)favoritesButton:(id)sender {
    SWRevealViewController* swRevealViewController = (SWRevealViewController*)self.parentViewController;
    swRevealViewController.frontViewController = departuresPageViewController;
    [swRevealViewController revealToggleAnimated:YES];
}

- (IBAction)organizeFavotitesButton:(id)sender {
    SWRevealViewController* swRevealViewController = (SWRevealViewController*)self.parentViewController;
    swRevealViewController.frontViewController = favoritesNavigationController;
    [swRevealViewController revealToggleAnimated:YES];
}

#pragma mark - Segues
- (IBAction)unwindFromDepartures:(UIStoryboardSegue *)segue {
    //Affichage du menu
    RevealViewController* revealViewController = (RevealViewController*)self.parentViewController;
    [revealViewController toggleViews];
}

- (IBAction)unwindFromFavorites:(UIStoryboardSegue *)segue {
    //Affichage des départs en front
    RevealViewController* revealViewController = (RevealViewController*)self.parentViewController;
    [revealViewController toggleViews];
}

@end
