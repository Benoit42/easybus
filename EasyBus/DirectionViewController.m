//
//  FlipsideViewController.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "DirectionViewController.h"
#import "FavoritesNavigationController.h"
#import "DirectionCell.h"

@implementation DirectionViewController

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
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Memory warning" message:@"In DirectionViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get departure section
    if (indexPath.row < 2) {
        static NSString *CellIdentifier = @"Cell";
        DirectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //get the favorite fromnav controler
        Favorite* favorite = ((FavoritesNavigationController*)self.navigationController)._currentFavorite;
        
        //get route
        Route* route = [_staticDataManager routesForId:favorite.ligne];

        //add departure
        NSString* libelle = (indexPath.row == 0) ? route._fromName : route._toName;
        [cell._libDirection setText:libelle];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //get the favorite fromnav controler
    Favorite* favorite = ((FavoritesNavigationController*)self.navigationController)._currentFavorite;
    
    //get route
    Route* route = [_staticDataManager routesForId:favorite.ligne];
    
    //update favorite
    favorite.direction = [NSString stringWithFormat:@"%i", indexPath.row];
    favorite.libDirection = route._toName;
}

@end
