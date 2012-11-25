//
//  FavoritesViewController.m
//  EasyBus
//
//  Created by Benoit on 13/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "FavoritesViewController.h"
#import "FavoritesNavigationController.h"
#import "Favorite.h"
#import "FavoriteCell.h"

@implementation FavoritesViewController

@synthesize _favoritesManager;

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Instanciates des data
    _favoritesManager = [FavoritesManager singleton];
    
    // Abonnement au notifications des favoris
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"favoritesUpdated" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Memory warning" message:@"In FavoritesViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
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
    return [[_favoritesManager favorites] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Get favorites
    NSArray* favorites = [_favoritesManager favorites];
    
    //get departure section
    if (indexPath.row < favorites.count) {
        static NSString *CellIdentifier = @"Cell";
        FavoriteCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //get the favorite
        Favorite* favorite = [favorites objectAtIndex:indexPath.row];

        //add departure
        [cell._picto setImage:favorite.picto];
        [cell._libArret setText:favorite.libArret];
        [cell._libDirection setText:favorite.libDirection];
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // delete your data item here
        NSArray* favorites = [_favoritesManager favorites];
        Favorite* favorite = [favorites objectAtIndex:indexPath.row];
        [_favoritesManager removeFavorite:favorite];

        // Animate the deletion from the table.
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

    }
}
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    //Get favorites
    NSArray* favorites = [_favoritesManager favorites];
    NSMutableArray* favoritesToDelete = [NSMutableArray new];
    
    //Remove deleted favorites
    for (NSIndexPath* indexPath in indexPaths) {
        //get the favorite
        Favorite* favorite = [favorites objectAtIndex:indexPath.row];
        [favoritesToDelete addObject:favorite];
    }
    for (Favorite* favorite in favoritesToDelete) {
        //delete the favorite
        [_favoritesManager removeFavorite:favorite];
    }

    //Refresh table (not necessary
    [((UITableView*)self.view) reloadData];
    return;
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"newFavorite"]) {
        // Alloc new clean favorite
        ((FavoritesNavigationController*)self.navigationController)._currentFavorite = [Favorite new];
    }
}

- (IBAction)unwindFromSave:(UIStoryboardSegue *)segue {
    // Save the favorite
    Favorite* favorite = ((FavoritesNavigationController*)self.navigationController)._currentFavorite;
    [_favoritesManager addFavorite:favorite];
    [((UITableView*)self.view) reloadData];
}

@end
