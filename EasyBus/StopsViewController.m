//
//  StopsViewControler.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "StopsViewController.h"
#import "FavoritesNavigationController.h"
#import "StopCell.h"

@implementation StopsViewController

@synthesize _staticDataManager, _saveButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Instanciates des data
    _staticDataManager = [StaticDataManager singleton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Memory warning" message:@"In StopsViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
    //get the favorite from nav controler
    Favorite* favorite = ((FavoritesNavigationController*)self.navigationController)._currentFavorite;

    // Return the number of rows in the section.
    return [[_staticDataManager stopsForRouteId:favorite.ligne direction:favorite.direction] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get the favorite from nav controler
    Favorite* favorite = ((FavoritesNavigationController*)self.navigationController)._currentFavorite;

    //get stop list
    NSArray* routeStops = [_staticDataManager stopsForRouteId:favorite.ligne direction:favorite.direction];

    //get departure section
    if (indexPath.row < [routeStops count]) {
        //get the stop
        RouteStop* routeStop = [routeStops objectAtIndex:indexPath.row];
        Stop* stop = [_staticDataManager stopForId:routeStop._stopId];
        
        static NSString *CellIdentifier = @"Cell";
        StopCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //add departure
        [cell._libArret setText:stop._name];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //get the current favorite fromnav controler
    Favorite* favorite = ((FavoritesNavigationController*)self.navigationController)._currentFavorite;

    //get selected stop
    NSArray* routeStops = [_staticDataManager stopsForRouteId:favorite.ligne direction:favorite.direction];
    RouteStop* routeStop = [routeStops objectAtIndex:indexPath.row];
    Stop* stop = [_staticDataManager stopForId:routeStop._stopId];
    
    // update it the current favorite
    favorite.arret = stop._id;
    favorite.libArret = stop._name;
    favorite.lat = [stop._lat doubleValue];
    favorite.lon = [stop._lon doubleValue];
    
    // activate save button
    [_saveButton setEnabled:YES];
}

@end
