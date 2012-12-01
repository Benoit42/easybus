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

@implementation DeparturesViewController

@synthesize _favoritesManager, _departuresManager, page, _activityIndicator, _arret, _direction;

NSInteger const MAXROWS = 6;

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Instanciates des data
    _favoritesManager = [FavoritesManager singleton];
    _departuresManager = [DeparturesManager singleton];
    
    // Abonnement au notifications des départs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedStarted:) name:@"departuresUpdateStarted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedSucceeded:) name:@"departuresUpdateSucceeded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdateFailed:) name:@"departuresUpdateFailed" object:nil];
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //update header
    Favorite* groupe = [[_favoritesManager groupes] objectAtIndex:page];
    [_arret setText:groupe.libArret];
    [_direction setText:[NSString stringWithFormat:@"vers %@", groupe.libDirection]];

    //update footer
    //TODO

}

#pragma mark - Saturation mémoire
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alerte mémoire" message:@"Dans DeparturesViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
}

#pragma mark - Erreurs sur la récupération des départs
- (void)departuresUpdateFailed:(NSNotification *)notification {
    // stop indicator
    [_activityIndicator stopAnimating];

    //show alert
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Erreur" message:@"Erreur lors de la récupération des départs" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Stuff for refreshing activity indicator
- (void)departuresUpdatedStarted:(NSNotification *)notification {
    // start indicator
    [_activityIndicator startAnimating];
}

#pragma mark - Stuff for refreshing view
- (void)departuresUpdatedSucceeded:(NSNotification *)notification {
    // stop indicator
    [_activityIndicator stopAnimating];

    // Refresh view
    [(UITableView*)self.view reloadData];
}

#pragma mark - Table view refresh control
- (IBAction)_refreshAsked:(UIButton *)sender {
    [_departuresManager refreshDepartures:[_favoritesManager favorites]];
}

#pragma mark - Table view data source
/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section plus header and footer
    // always header + footer + iphone5->5, other->4
    return MAXROWS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get favorite
    Favorite* groupe = [[_favoritesManager groupes] objectAtIndex:page];
    NSArray* departures = [_departuresManager getDeparturesForGroupe:groupe];
    UITableViewCell* cell = nil;
    
    if (indexPath.row < [departures count] ){
        // departure row
        
        //get cell and update it
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        NSInteger departureIndex = indexPath.row;
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
