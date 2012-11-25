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

@interface DeparturesViewController()

@property(strong, nonatomic) NSArray* _sections;

@end

@implementation DeparturesViewController

@synthesize _favoritesManager, _departuresManager;

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Instanciates des data
    _favoritesManager = [FavoritesManager singleton];
    _departuresManager = [DeparturesManager singleton];
    
    // Ajout du widget de refresh
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];

    // Abonnement au notifications des départs
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"departuresUpdated" object:nil];

    //[self refreshData];
}

#pragma mark - Saturation mémoire
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alerte mémoire" message:@"Dans DeparturesViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
}

#pragma mark - Stuff for refreshing view
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Raffraichissement des données
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
    return [[_favoritesManager groupes] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section plus header and footer
    Favorite* groupe = [[_favoritesManager groupes] objectAtIndex:section];
    NSArray* departures = [_departuresManager getDeparturesForGroupe:groupe];
    if ([departures count] == 0) {
        //Pas de départ, on a seulement le header et le "Pas de départ"
        return 2;
    }
    else {
        return [departures count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get favorite
    Favorite* groupe = [[_favoritesManager groupes] objectAtIndex:indexPath.section];
    NSArray* departures = [_departuresManager getDeparturesForGroupe:groupe];
    
    if (indexPath.row == 0) {
        //Header row
        
        //get cell and update it
        DepartureHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Header"];
        [[cell _libStop] setText:groupe.libArret];
        [[cell _libDirection] setText:[NSString stringWithFormat:@"vers %@", groupe.libDirection]];
        return cell;
    }
    else {
        if ([departures count] == 0) {
            //Aucun départ

            //get cell and update it
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noDeparture" forIndexPath:indexPath];
            [[cell textLabel] setText:@"Aucun départ"];
            [[cell textLabel] setTextAlignment:NSTextAlignmentCenter];
            return cell;
        }
        else if (indexPath.row < [departures count] + 1) {
            // departure row
            
            //get departure
            NSInteger departureIndex = indexPath.row - 1;
            Depart* depart = [departures objectAtIndex:departureIndex];
            
            //get cell and update it
            DepartureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            [[cell _picto] setImage:depart.picto];
            NSString* libDelai;
            if (depart._delai < 60*60) {
                libDelai = [NSString stringWithFormat:@"%i min", (int)(depart._delai/60)];
            }
            else {
                libDelai = @"> 1h";
            }
            [[cell _delai] setText:libDelai];
            return cell;
        }
    }
    return nil;
}

@end
