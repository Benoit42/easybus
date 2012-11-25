//
//  FlipsideViewController.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "LinesViewController.h"
#import "FavoritesNavigationController.h"
#import "LineCell.h"

@implementation LinesViewController

@synthesize _staticDataManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Instanciates des data
    _staticDataManager = [StaticDataManager singleton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Memory warning" message:@"In LinesViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
    return [[_staticDataManager routes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* routes = [_staticDataManager routes];
    
    //get routes section
    if (indexPath.row < [routes count]) {
        static NSString *CellIdentifier = @"Cell";
        LineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //get route
        Route* route = [routes objectAtIndex:indexPath.row];
        
        //add departure
        [cell._picto setImage:route.picto];
        [cell._libLigne setText:route._longName];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //get route
    Route* route = [[_staticDataManager routes] objectAtIndex:indexPath.row];

    //get the current favorite fromnav controler and update it
    Favorite* favorite = ((FavoritesNavigationController*)self.navigationController)._currentFavorite;    
    favorite.ligne = route._id;
    favorite.libLigne = route._shortName;
}

#pragma mark - Segues
- (IBAction)newFavorite:(UIStoryboardSegue *)segue {
    // Create the favorite
    ((FavoritesNavigationController*)self.navigationController)._currentFavorite = [Favorite new];
}


@end
