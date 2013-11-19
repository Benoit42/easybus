//
//  FlipsideViewController.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "LinesViewController.h"
#import "LinesNavigationController.h"
#import "FavoritesManager.h"
#import "LineCell.h"
#import "Route+RouteWithAdditions.m"

@implementation LinesViewController

objection_requires(@"favoritesManager", @"staticDataManager", @"gtfsDownloadManager")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Pré-conditions
    NSAssert(self.staticDataManager != nil, @"staticDataManager should not be nil");
    NSAssert(self.gtfsDownloadManager != nil, @"gtfsDownloadManager should not be nil");
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
    return [[self.staticDataManager routes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* routes = [self.staticDataManager routes];
    
    //get routes section
    if (indexPath.row < [routes count]) {
        static NSString *CellIdentifier = @"Cell";
        LineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //get route
        Route* route = [routes objectAtIndex:indexPath.row];
        
        //add departure
        [cell._picto setImageWithURL:route.pictoUrl];
        [cell._libLigne setText:route.longName];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //get route
    Route* route = [[self.staticDataManager routes] objectAtIndex:indexPath.row];

    //get the current favorite fromnav controler and update it
    ((LinesNavigationController*)self.navigationController).currentFavoriteRoute = route;
}

#pragma mark ajout du favoris
- (IBAction)unwindFromSave:(UIStoryboardSegue *)segue {
    //Create the favorite
    Route* route = ((LinesNavigationController*)self.navigationController).currentFavoriteRoute;
    Stop* stop = ((LinesNavigationController*)self.navigationController).currentFavoriteStop;
    NSString* direction = ((LinesNavigationController*)self.navigationController).currentFavoriteDirection;
    [self.favoritesManager addFavorite:route stop:stop direction:direction];
}

@end
