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

@property(nonatomic) NSDateFormatter *_timeIntervalFormatter;
@property(nonatomic) NSUInteger _maxRows;

@end

@implementation DeparturesViewController

@synthesize _favoritesManager, _departuresManager, page, _activityIndicator, _arret, _direction, _info, _timeIntervalFormatter, _maxRows;

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Instanciates des data
    _favoritesManager = [FavoritesManager singleton];
    _departuresManager = [DeparturesManager singleton];
    
    _timeIntervalFormatter = [[NSDateFormatter alloc] init];
    _timeIntervalFormatter.timeStyle = NSDateFormatterFullStyle;
    _timeIntervalFormatter.dateFormat = @"HH:mm";

    //check resolution
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 480) {
        _maxRows = 3;
    }
    else {
        _maxRows = 4;
    }
    
    // Abonnement au notifications des départs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedStarted:) name:@"departuresUpdateStarted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedSucceeded:) name:@"departuresUpdateSucceeded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdateFailed:) name:@"departuresUpdateFailed" object:nil];

    //refresh departures
    NSArray* favorite = [[FavoritesManager singleton] favorites];
    [[DeparturesManager singleton] refreshDepartures:favorite];
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //update header
    NSArray* groupes = [_favoritesManager groupes];
    if (page < [groupes count]) {
        Favorite* groupe = [groupes objectAtIndex:page];
        [_arret setText:groupe.libArret];
        [_direction setText:[NSString stringWithFormat:@"vers %@", groupe.libDirection]];
    }
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

    //message
    [_info setText:@"erreur lors de la mise à jour..."];
}

#pragma mark - Stuff for refreshing activity indicator
- (void)departuresUpdatedStarted:(NSNotification *)notification {
    // start indicator
    [_activityIndicator startAnimating];
    
    //message
    [_info setText:@"mise à jour..."];
}

#pragma mark - Stuff for refreshing view
- (void)departuresUpdatedSucceeded:(NSNotification *)notification {
    // stop indicator
    [_activityIndicator stopAnimating];

    // Refresh view
    [(UITableView*)self.view reloadData];

    //message
    NSString* maj = [_timeIntervalFormatter stringFromDate:[NSDate date]];
    [_info setText:[[NSString alloc] initWithFormat:@"mis à jour à %@", maj]];
}

#pragma mark - Table view refresh control
- (IBAction)_refreshAsked:(UIButton *)sender {
    [_departuresManager refreshDepartures:[_favoritesManager favorites]];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section plus header and footer
    // always header + footer + iphone5->5, other->4
    NSArray* groupes = [_favoritesManager groupes];
    if (page < [groupes count]) {
        return _maxRows;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //create cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    //get departures
    Favorite* groupe = [[_favoritesManager groupes] objectAtIndex:page];
    NSArray* departures = [_departuresManager getDeparturesForGroupe:groupe];
    if (indexPath.row < [departures count] ){
        // departure row
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
            [[(DepartureCell*)cell _message] setText:nil];
        }
    }
    else {
        // no departure row
        [[(DepartureCell*)cell _picto] setImage:nil];
        [[(DepartureCell*)cell _delai] setText:nil];
        if (indexPath.row == 0) {
            [[(DepartureCell*)cell _message] setText:@"aucun départ"];
        }
        else {
            [[(DepartureCell*)cell _message] setText:nil];
        }
    }
    return cell;
}

@end
