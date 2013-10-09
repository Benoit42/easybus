//
//  FlipsideViewController.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "LinesViewController.h"
#import "FavoritesNavigationController.h"
#import "DirectionViewController.h"
#import "LineCell.h"

@implementation LinesViewController

objection_requires(@"staticDataManager", @"staticDataLoader")
@synthesize staticDataManager, staticDataLoader;

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Pré-conditions
    NSAssert(self.staticDataManager != nil, @"staticDataManager should not be nil");
    NSAssert(self.staticDataLoader != nil, @"staticDataLoader should not be nil");

    //Pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:nil action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

#pragma mark - Refresh Keolis data
-(void) updateData{
    [self.staticDataLoader loadStaticData];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
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
        UIImage* picto = [staticDataManager pictoForRouteId:route.shortName];
        [cell._picto setImage:picto];
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
    ((FavoritesNavigationController*)self.navigationController)._currentFavoriteRoute = route;
}

@end
