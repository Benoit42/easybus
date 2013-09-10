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

@synthesize favoritesManager, staticDataManager, groupManager, addButton, editing;

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
    self.groupManager = ((FavoritesNavigationController*)self.navigationController).groupManager;
    self.editing = [NSNumber numberWithBool:FALSE];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Si aucun favori, passage direct à l'écran des lignes
    NSArray* favorites = [self.favoritesManager favorites];
    if ([favorites count] == 0) {
        [self performSegueWithIdentifier: @"chooseLine" sender: self];
    }
    else {
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 1.0; //seconds
        lpgr.delegate = self;
        [self.tableView addGestureRecognizer:lpgr];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSUInteger count = [[self.groupManager groups] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    Group* group = [[self.groupManager groups] objectAtIndex:section];
    NSUInteger count = [group.favorites count];
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < [[self.groupManager groups] count]) {
        Group* group = [[self.groupManager groups] objectAtIndex:section];
        
        //add departure
        return [NSString stringWithFormat:@"vers %@", group.terminus];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Get favorites
    Group* group = [[self.groupManager groups] objectAtIndex:indexPath.section];
    NSOrderedSet* favorites = group.favorites;
    
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
        //begin editing update
        [self.tableView beginUpdates];
        
        // delete your data item here
        Group* group = [[self.groupManager groups] objectAtIndex:indexPath.section];
        Favorite* favorite = [[group favorites] objectAtIndex:indexPath.row];
        [self.favoritesManager removeFavorite:favorite];

        // Animate the deletion from the table
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (group.favorites.count == 0) {
            NSIndexSet *sections = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.section, 1)];
            [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
        }

        //end editing update
        [self.tableView endUpdates];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //begin editing update
    [self.tableView beginUpdates];

    //Get source group
    Group* sourceGroup = [[self.groupManager groups] objectAtIndex:sourceIndexPath.section];
    
    //Get favorite
    Favorite* favorite = [[sourceGroup favorites] objectAtIndex:sourceIndexPath.row];

    //Get destination group
    Group* destinationGroup = [[self.groupManager groups] objectAtIndex:destinationIndexPath.section];

    //Move favorite
    [favoritesManager moveFavorite:favorite fromGroup:sourceGroup toGroup:destinationGroup atIndex:destinationIndexPath.row];
    if (sourceGroup.favorites.count == 0) {
        NSIndexSet *sections = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(sourceIndexPath.section, 1)];
        [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
    }

    //end editing update
    [self.tableView endUpdates];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    [self.tableView setEditing:YES animated:YES];
    [addButton setTitle:@"Fin"];
    self.editing = [NSNumber numberWithBool:TRUE];
}

- (IBAction)addButtonPressed:(id)sender {
    if (self.editing.boolValue == TRUE) {
        [self.tableView setEditing:NO animated:YES];
        [addButton setTitle:@"+"];
        self.editing = [NSNumber numberWithBool:FALSE];
    }
}

#pragma mark - Segues
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"chooseLine"]) {
        if (self.editing.boolValue == YES) {
            [self.tableView setEditing:NO animated:YES];
            [addButton setTitle:@"+"];
            self.editing = [NSNumber numberWithBool:NO];
            return FALSE;
        }
    }
    
    return TRUE;
}

- (IBAction)unwindFromSave:(UIStoryboardSegue *)segue {
    //Create the favorite
    Route* route = ((FavoritesNavigationController*)self.navigationController)._currentFavoriteRoute;
    Stop* stop = ((FavoritesNavigationController*)self.navigationController)._currentFavoriteStop;
    NSString* direction = ((FavoritesNavigationController*)self.navigationController)._currentFavoriteDirection;
    [self.favoritesManager addFavorite:route stop:stop direction:direction];
    [((UITableView*)self.view) reloadData];
}

@end
