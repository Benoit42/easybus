//
//  FavoriteInitViewController.m
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "FavoriteInitViewController.h"
#import "FavoritesNavigationController.h"

@interface FavoriteInitViewController ()

@end

@implementation FavoriteInitViewController

@synthesize managedObjectContext, favoritesManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Memory warning" message:@"In FavoriteInitViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
}

#pragma mark - Segues
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"addFavorite"]) {
        FavoritesNavigationController* destinationViewController = (FavoritesNavigationController*)[segue destinationViewController];
        destinationViewController.managedObjectContext = self.managedObjectContext;
        destinationViewController.favoritesManager = self.favoritesManager;
    }
}

@end
