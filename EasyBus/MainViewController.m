//
//  MainViewController.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "MainViewController.h"
#import "FavoritesNavigationController.h"
#import "PageViewController.h"

@implementation MainViewController

@synthesize _refreshDate, _containerView, _pageViewController;

#pragma mark - Saturation mémoire
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alerte mémoire" message:@"Dans MainViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
}

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //abo au notifications de mis à jour
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDeparturesNotification:)
                                                 name:@"departuresUpdated"
                                               object:nil];

    
    //on créé le page view controller si nécessaire
    PageViewController *pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    [self addChildViewController:pageViewController];
    [_containerView addSubview:pageViewController.view ];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = _containerView.bounds;
    pageViewController.view.frame = pageViewRect;
}

#pragma mark - nettoyage
- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateDeparturesNotification:(NSNotification *)notification
{
    //Refresh de la date
    static NSDateFormatter *timeIntervalFormatter;
    if (!timeIntervalFormatter) {
        timeIntervalFormatter = [[NSDateFormatter alloc] init];
        timeIntervalFormatter.timeStyle = NSDateFormatterFullStyle;
        timeIntervalFormatter.dateFormat = @"HH:mm";
    }
    NSString* maj = [timeIntervalFormatter stringFromDate:[NSDate date]];
    [_refreshDate setText:[[NSString alloc] initWithFormat:@"mis à jour à %@", maj]];
}

#pragma mark - Segues
- (IBAction)unwindFromAlternate:(UIStoryboardSegue *)segue {
    //Rechargement des départs
    NSArray* favorite = [[FavoritesManager singleton] favorites];
    [[DeparturesManager singleton] refreshDepartures:favorite];

}

@end
