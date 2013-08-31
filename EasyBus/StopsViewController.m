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

@synthesize staticDataManager, _saveButton;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize data
    self.staticDataManager = ((FavoritesNavigationController*)self.navigationController).staticDataManager;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Memory warning" message:@"In StopsViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //get the current route and direction
    Route* route = ((FavoritesNavigationController*)self.navigationController)._currentFavoriteRoute;
    NSString* direction = ((FavoritesNavigationController*)self.navigationController)._currentFavoriteDirection;
    
    // Return the number of rows in the section
    return [[self.staticDataManager stopsForRoute:route direction:direction] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get the current route and direction
    Route* route = ((FavoritesNavigationController*)self.navigationController)._currentFavoriteRoute;
    NSString* direction = ((FavoritesNavigationController*)self.navigationController)._currentFavoriteDirection;
    
    //get stop list
    NSArray* stops = [self.staticDataManager stopsForRoute:route direction:direction];
    
    //get departure section
    if (indexPath.row < [stops count]) {
        //get the stop
        Stop* stop = [stops objectAtIndex:indexPath.row];
        
        static NSString *CellIdentifier = @"Cell";
        StopCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //add departure
        [cell._libArret setText:stop.name];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //get the current route and direction
    Route* route = ((FavoritesNavigationController*)self.navigationController)._currentFavoriteRoute;
    NSString* direction = ((FavoritesNavigationController*)self.navigationController)._currentFavoriteDirection;
    
    //get the current stop
    NSArray* stops = [self.staticDataManager stopsForRoute:route direction:direction];
    Stop* stop = [stops objectAtIndex:indexPath.row];
    
    // update it the current favorite
    ((FavoritesNavigationController*)self.navigationController)._currentFavoriteStop = stop;
    
    // activate save button
    [_saveButton setEnabled:YES];
}

@end
