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

@implementation MenuViewController {
    UIViewController* departuresPageViewController;
    UIViewController* favoritesNavigationController;
    UIViewController* linesNavigationController;
    UIViewController* creditsNavigationController;
    UIViewController* feedInfoNavigationViewController;
}

objection_requires(@"favoritesManager")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Instanciation des controllers
    departuresPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    favoritesNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritesNavigationController"];
    linesNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"LinesNavigationController"];
    creditsNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreditsNavigationController"];
    feedInfoNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedInfoNavigationController"];
    
    //Si pas de favoris, on passe sur la liste des lignes
    if (self.favoritesManager.favorites.count == 0) {
        SWRevealViewController* swRevealViewController = (SWRevealViewController*)self.parentViewController;
        swRevealViewController.frontViewController = linesNavigationController;
    }
    
    //Affichage du n° de version
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.versionLabel.text = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Mise à jour de l'UI
    BOOL haveFavorites = self.favoritesManager.favorites.count > 0;
    self.favoritesButton.enabled = haveFavorites;
    self.organizeButton.enabled = haveFavorites;
}

#pragma mark - Actions
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

- (IBAction)feedInfoButton:(id)sender {
    SWRevealViewController* swRevealViewController = (SWRevealViewController*)self.parentViewController;
    swRevealViewController.frontViewController = feedInfoNavigationViewController;
    [swRevealViewController revealToggleAnimated:YES];
}

#pragma mark - Segues
- (IBAction)unwindToMenu:(UIStoryboardSegue *)segue {
    //Affichage du menu
    RevealViewController* revealViewController = (RevealViewController*)self.parentViewController;
    [revealViewController toggleViews];
}

@end
