//
//  RevealViewController.m
//  EasyBus
//
//  Created by Benoit on 05/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "RevealViewController.h"
#import "MenuViewController.h"
#import "NSManagedObjectContext+Favorite.h"

@implementation RevealViewController
objection_requires(@"managedObjectContext")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);

    //Instanciation des controllers
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    self.departuresPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.favoritesNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritesNavigationController"];
    self.linesNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"LinesNavigationController"];
    self.creditsNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreditsNavigationController"];
    self.feedInfoNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedInfoNavigationController"];
    
    //Pas d'interaction lorsque le menu est affiché
    [self tapGestureRecognizer];
    
    //Affectation des vues
    self.rearViewController = self.menuViewController;
    if (self.managedObjectContext.favorites.count == 0) {
        //Si pas de favoris, on affiche la liste des lignes
        self.frontViewController = self.linesNavigationController;
    }
    else {
        //Sinon on affiche la liste des départs
        self.frontViewController = self.departuresPageViewController;
    }
}

- (void) showDepartures {
    [self setFrontViewController:self.departuresPageViewController animated:YES];
}

- (void) showLines {
    [self setFrontViewController:self.linesNavigationController animated:YES];
}

- (void) showFavorites {
    [self setFrontViewController:self.favoritesNavigationController animated:YES];
}

- (void) showCredits {
    [self setFrontViewController:self.creditsNavigationController animated:YES];
}

- (void) showFeedInfo {
    [self setFrontViewController:self.feedInfoNavigationViewController animated:YES];
}

- (void) showMenu {
    [self revealToggleAnimated:YES];
}

@end
