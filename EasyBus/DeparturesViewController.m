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
    return [[_favoritesManager groupes] count] ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    Favorite* groupe = [[_favoritesManager groupes] objectAtIndex:section];
    NSArray* departures = [_departuresManager getDeparturesForGroupe:groupe];
    return [departures count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get departure
    Favorite* groupe = [[_favoritesManager groupes] objectAtIndex:indexPath.section];
    NSArray* departures = [_departuresManager getDeparturesForGroupe:groupe];
    
    if (indexPath.row < [departures count]) {
        static NSString *CellIdentifier = @"Cell";
        DepartureCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //get departure
        Depart* depart = [departures objectAtIndex:indexPath.row];
        
        //get bus
        NSInteger ligne = [depart._ligne intValue];
        
        //add departure
        UIImage* picto = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Pictogrammes_100-%i", ligne] ofType:@"png"]];
        [[cell _picto] setImage:picto];
        NSString* libDelai;
        if (depart._delai >0 && depart._delai < 60*60) {
            libDelai = [NSString stringWithFormat:@"%i min", (int)(depart._delai/60)];
        }
        else {
            libDelai = @"> 1h";
        }
        [[cell _delai] setText:libDelai];
        return cell;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Favorite* groupe = [[_favoritesManager groupes] objectAtIndex:section];
    return [NSString stringWithFormat:@"%@ vers %@", groupe.libArret, groupe.libDirection];
}

@end
