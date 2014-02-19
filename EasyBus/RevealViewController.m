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
#import "NSManagedObjectContext+Trip.h"

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
    self.departuresViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DeparturesPageViewController"];
    self.nearStopsController = [self.storyboard instantiateViewControllerWithIdentifier:@"NearStopsNavigationController"];
    self.favoritesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritesNavigationController"];
    self.linesViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LinesNavigationController"];
    self.creditsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CreditsNavigationController"];
    self.feedInfoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedInfoNavigationController"];
    
    //Pas d'interaction lorsque le menu est affiché
    [self tapGestureRecognizer];
    
    //Affectation des vues
    if (self.managedObjectContext.trips.count == 0) {
        //Si pas de favoris, on affiche la liste des lignes
        self.frontViewController = self.linesViewController;
    }
    else {
        //Sinon on affiche la liste des départs
        self.frontViewController = self.departuresViewController;
    }
}

- (void) showDepartures {
    [self setFrontViewController:self.departuresViewController animated:YES];
}

- (void) showMap {
    [self setFrontViewController:self.nearStopsController animated:YES];
}

- (void) showLines {
    [self setFrontViewController:self.linesViewController animated:YES];
}

- (void) showFavorites {
    [self setFrontViewController:self.favoritesViewController animated:YES];
}

- (void) showCredits {
    [self setFrontViewController:self.creditsViewController animated:YES];
}

- (void) showFeedInfo {
    [self setFrontViewController:self.feedInfoViewController animated:YES];
}

- (void) showMenu {
    [self revealToggleAnimated:YES];
}

@end
