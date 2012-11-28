//
//  DeparturesViewController.m
//  EasyBus
//
//  Created by Benoit on 11/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "DeparturesViewController.h"
#import "FavoritesManager.h"
#import "DeparturesManager.h"
#import "DepartureCell.h"
#import "DepartureHeaderCell.h"
#import "DepartureFooterCell.h"

@implementation DeparturesViewController

@synthesize _favoritesManager, _departuresManager, page;

NSInteger const MAXROWS = 5;

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Instanciates des data
    _favoritesManager = [FavoritesManager singleton];
    _departuresManager = [DeparturesManager singleton];
    
    // Ajout du widget de refresh
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];

    // Abonnement au notifications des favoris
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"updateFavorites" object:nil];

    // Get data for favorites
    NSArray* favorite = [_favoritesManager favorites];
    [_departuresManager loadDeparturesFromKeolis:favorite];
}

#pragma mark - Saturation mémoire
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alerte mémoire" message:@"Dans DeparturesViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
}

#pragma mark - Stuff for refreshing view
- (void)refreshData:(NSNotification *)notification {
    // Refresh date
    [self refreshData];
}

- (void)refreshData {
    // Get data for favorites
    NSArray* favorite = [_favoritesManager favorites];
    [_departuresManager loadDeparturesFromKeolis:favorite];

    // Refresh view
    [(UITableView*)self.view reloadData];
}

#pragma mark - Table view refresh control
- (void)refreshView:(UIRefreshControl *)refresh {
    [self refreshData];
    [refresh endRefreshing];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section plus header and footer
    // always header + footer + iphone5->5, other->4
    return 1 + MAXROWS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get favorite
    Favorite* groupe = [[_favoritesManager groupes] objectAtIndex:page];
    NSArray* departures = [_departuresManager getDeparturesForGroupe:groupe];
    UITableViewCell* cell = nil;
    
    if (indexPath.row == 0) {
        //Header row
        
        //get cell and update it
        cell = [tableView dequeueReusableCellWithIdentifier:@"Header"];
        [[(DepartureHeaderCell*)cell _libStop] setText:groupe.libArret];
        [[(DepartureHeaderCell*)cell _libDirection] setText:[NSString stringWithFormat:@"vers %@", groupe.libDirection]];
    }
    else if (indexPath.row <= [departures count] ){
        // departure row
        
        //get cell and update it
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        NSInteger departureIndex = indexPath.row - 1;
        if (departureIndex < [departures count]) {
            //get departure
            Depart* depart = [departures objectAtIndex:departureIndex];
            
            //update cell
            [[(DepartureCell*)cell _picto] setImage:depart.picto];
            NSString* libDelai;
            if (depart._delai < 60*60) {
                libDelai = [NSString stringWithFormat:@"%i min", (int)(depart._delai/60)];
            }
            else {
                libDelai = @"> 1h";
            }
            [[(DepartureCell*)cell _delai] setText:libDelai];
        }
    }
    else {
        // no departure row
        
        //get cell and return it
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        [[(DepartureCell*)cell _picto] setImage:nil];
        [[(DepartureCell*)cell _delai] setText:nil];
    }
    return cell;
}

@end
