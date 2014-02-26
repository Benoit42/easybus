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
#import "NSManagedObjectContext+Group.h"

@implementation MenuViewController
objection_requires(@"managedObjectContext")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
    
    //Affichage du n° de version
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.versionLabel.text = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Mise à jour de l'UI
    BOOL haveFavorites = YES;// self.managedObjectContext.allGroups.count > 0;
    self.favoritesButton.enabled = haveFavorites;
    self.organizeButton.enabled = haveFavorites;
}

#pragma mark - Actions
- (IBAction)favoritesButton:(id)sender {
    RevealViewController* revealViewController = (RevealViewController*)self.parentViewController;
    [revealViewController showDepartures];
}

- (IBAction)nearbyButton:(id)sender {
    RevealViewController* revealViewController = (RevealViewController*)self.parentViewController;
    [revealViewController showMap];
}

- (IBAction)linesButton:(id)sender {
    RevealViewController* revealViewController = (RevealViewController*)self.parentViewController;
    [revealViewController showLines];
}

- (IBAction)organizeButton:(id)sender {
    RevealViewController* revealViewController = (RevealViewController*)self.parentViewController;
    [revealViewController showFavorites];
}

- (IBAction)creditsButton:(id)sender {
    RevealViewController* revealViewController = (RevealViewController*)self.parentViewController;
    [revealViewController showCredits];
}

- (IBAction)feedInfoButton:(id)sender {
    RevealViewController* revealViewController = (RevealViewController*)self.parentViewController;
    [revealViewController showFeedInfo];
}

#pragma mark - Segues
- (IBAction)unwindToMenu:(UIStoryboardSegue *)segue {
    RevealViewController* revealViewController = (RevealViewController*)self.parentViewController;
    //Affichage du menu
    [revealViewController showMenu];
}

@end
