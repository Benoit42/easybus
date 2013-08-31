//
//  FavoritesViewController.m
//  EasyBus
//
//  Created by Benoit on 13/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "FavoritesViewController.h"
#import "FavoritesNavigationController.h"
#import "LinesViewController.h"
#import "Favorite.h"
#import "Route+RouteWithAdditions.h"
#import "Stop.h"
#import "FavoriteCell.h"
#import "StaticDataManager.h"

@implementation FavoritesViewController

@synthesize managedObjectContext, favoritesManager;

#pragma mark - Saturation mémoire
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Memory warning" message:@"In FavoritesViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
}

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize data
    self.staticDataManager = ((FavoritesNavigationController*)self.navigationController).staticDataManager;
    self.favoritesManager = ((FavoritesNavigationController*)self.navigationController).favoritesManager;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Si aucun favori, passage direct à l'écran des lignes
    NSArray* favorites = [self.favoritesManager favorites];
    if ([favorites count] == 0) {
        [self performSegueWithIdentifier: @"chooseLine" sender: self];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.favoritesManager favorites] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Get favorites
    NSArray* favorites = [self.favoritesManager favorites];
    
    //get departure section
    if (indexPath.row < favorites.count) {
        static NSString *CellIdentifier = @"Cell";
        FavoriteCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //get the favorite
        Favorite* favorite = [favorites objectAtIndex:indexPath.row];

        //add departure
        UIImage *picto =  [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Pictogrammes_100\\%i", [favorite.route.id intValue]] ofType:@"png"]];
        [cell._picto setImage:picto];
        [cell._libArret setText:favorite.stop.name];
        [cell._libDirection setText:[favorite.route terminusForDirection:favorite.direction]];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // delete your data item here
        NSArray* favorites = [self.favoritesManager favorites];
        Favorite* favorite = [favorites objectAtIndex:indexPath.row];
        [self.favoritesManager removeFavorite:favorite];

        // Animate the deletion from the table.
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    //Get favorites
    NSArray* favorites = [self.favoritesManager favorites];
    NSMutableArray* favoritesToDelete = [NSMutableArray new];
    
    //Remove deleted favorites
    for (NSIndexPath* indexPath in indexPaths) {
        //get the favorite
        Favorite* favorite = [favorites objectAtIndex:indexPath.row];
        [favoritesToDelete addObject:favorite];
    }
    for (Favorite* favorite in favoritesToDelete) {
        //delete the favorite
        [self.favoritesManager removeFavorite:favorite];
    }

    //Refresh table (not necessary
    [((UITableView*)self.view) reloadData];
    return;
}

- (IBAction)unwindFromSave:(UIStoryboardSegue *)segue {
    // Save the favorite
    Route* route = ((FavoritesNavigationController*)self.navigationController)._currentFavoriteRoute;
    Stop* stop = ((FavoritesNavigationController*)self.navigationController)._currentFavoriteStop;
    NSString* direction = ((FavoritesNavigationController*)self.navigationController)._currentFavoriteDirection;
    [self.favoritesManager addFavorite:route stop:stop direction:direction];
    [((UITableView*)self.view) reloadData];
}

@end
