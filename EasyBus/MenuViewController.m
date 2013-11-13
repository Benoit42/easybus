//
//  MenuViewController.m
//  EasyBus
//
//  Created by Benoit on 04/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "MenuViewController.h"
#import "RevealViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController {
    UIViewController* departuresPageViewController;
    UIViewController* favoritesNavigationController;
    UIViewController* linesNavigationController;
    UIViewController* creditsNavigationController;
}

objection_requires(@"favoritesManager")

- (void)viewDidLoad {
    [super viewDidLoad];
    
    departuresPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    favoritesNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritesNavigationController"];
    linesNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"LinesNavigationController"];
    creditsNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreditsNavigationController"];
    
    //Si pas de favoris, on passe sur la liste des lignes
    if (self.favoritesManager.favorites.count == 0) {
        SWRevealViewController* swRevealViewController = (SWRevealViewController*)self.parentViewController;
        swRevealViewController.frontViewController = linesNavigationController;
    }   
}

- (IBAction)favoritesButton:(id)sender {
    SWRevealViewController* swRevealViewController = (SWRevealViewController*)self.parentViewController;
    swRevealViewController.frontViewController = departuresPageViewController;
    [swRevealViewController revealToggleAnimated:YES];
}

- (IBAction)linesButton:(id)sender {
    SWRevealViewController* swRevealViewController = (SWRevealViewController*)self.parentViewController;
    swRevealViewController.frontViewController = linesNavigationController;
    [swRevealViewController revealToggleAnimated:YES];
}

- (IBAction)organizeButton:(id)sender {
    SWRevealViewController* swRevealViewController = (SWRevealViewController*)self.parentViewController;
    swRevealViewController.frontViewController = favoritesNavigationController;
    [swRevealViewController revealToggleAnimated:YES];
}

- (IBAction)creditsButton:(id)sender {
    SWRevealViewController* swRevealViewController = (SWRevealViewController*)self.parentViewController;
    swRevealViewController.frontViewController = creditsNavigationController;
    [swRevealViewController revealToggleAnimated:YES];
}

#pragma mark - Segues
- (IBAction)unwindToMenu:(UIStoryboardSegue *)segue {
    //Affichage du menu
    RevealViewController* revealViewController = (RevealViewController*)self.parentViewController;
    [revealViewController toggleViews];
}

@end
