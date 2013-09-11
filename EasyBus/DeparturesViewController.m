//
//  DeparturesViewController.m
//  EasyBus
//
//  Created by Benoit on 11/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "DeparturesViewController.h"
#import "PageViewController.h"
#import "FavoritesNavigationController.h"
#import "DepartureCell.h"
#import "NoDepartureCell.h"
#import "Route+RouteWithAdditions.h"
#import "Stop.h"

@interface DeparturesViewController()

@property(nonatomic) NSDateFormatter* _timeIntervalFormatter;
@property(nonatomic) NSUInteger _maxRows;
@property(nonatomic) NSDate* _lastRefresh;
@property(nonatomic) BOOL _refreshing;

@end

@implementation DeparturesViewController

@synthesize favoritesManager, groupManager, departuresManager, staticDataManager, page, _activityIndicator, _reloadButton, _direction, _info, _timeIntervalFormatter, _maxRows, _lastRefresh, _refreshing;

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Instanciates des data
    _refreshing = FALSE;
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
    
    //Mise à jour des widgets
    [_activityIndicator stopAnimating];
    [_info setText:@""];
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //update header
    NSArray* groups = [self.groupManager groups];
    if (page < [groups count]) {
        Group* group = [groups objectAtIndex:page];
        [_direction setText:[NSString stringWithFormat:@"vers %@", group.terminus]];
    }
    
    //update footer
    NSDate* refreshDate = [self.departuresManager _refreshDate];
    if (refreshDate) {
        NSString* maj = [_timeIntervalFormatter stringFromDate:refreshDate];
        NSString* infoText = self._refreshing?@"":[[NSString alloc] initWithFormat:@"mis à jour à %@", maj];
        [_info setText:infoText];
    }
    
    //Compute refresh delay
    NSTimeInterval interval = [[self.departuresManager _refreshDate] timeIntervalSinceNow];
    if (interval > 60) {
        //refresh si plus d'1 minute
        [self.departuresManager refreshDepartures:[self.favoritesManager favorites]];
    }
}

#pragma mark - Saturation mémoire
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alerte mémoire" message:@"Dans DeparturesViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
}

#pragma mark - Gestion de la mise à jour des départs
- (void)departuresUpdatedStarted:(NSNotification *)notification {
    // start indicator
    [_activityIndicator startAnimating];
    
    //message
    _refreshing = TRUE;
    [_info setText:@""];
}

#pragma mark - Stuff for refreshing view
- (void)departuresUpdatedSucceeded:(NSNotification *)notification {
    // stop indicator
    [_activityIndicator stopAnimating];

    // Refresh view
    [(UITableView*)self.view reloadData];

    //message
    _refreshing = FALSE;
    NSString* maj = [_timeIntervalFormatter stringFromDate:[NSDate date]];
    [_info setText:[[NSString alloc] initWithFormat:@"mis à jour à %@", maj]];
}

- (void)departuresUpdateFailed:(NSNotification *)notification {
    // stop indicator
    [_activityIndicator stopAnimating];
    [_reloadButton setHidden:FALSE];
    
    //message
    _refreshing = FALSE;
    [_info setText:@"erreur lors de la mise à jour des départs"];
}

#pragma mark - Table view refresh control
- (IBAction)_refreshAsked:(UIButton *)sender {
    [self.departuresManager refreshDepartures:[self.favoritesManager favorites]];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section plus header and footer
    // always header + footer + iphone5->5, other->4
    NSArray* groupes = [self.groupManager groups];
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
    UITableViewCell* cell;

    //get departures
    Group* groupe = [[self.groupManager groups] objectAtIndex:page];
    NSArray* departures = [self.departuresManager getDeparturesForGroupe:groupe];
    if (indexPath.row < [departures count] ){
        // departure row
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        NSInteger departureIndex = indexPath.row;
        if (departureIndex < [departures count]) {
            //get departure
            Depart* depart = [departures objectAtIndex:departureIndex];
        
            //update cell
            UIImage* picto = [staticDataManager pictoForRouteId:depart.route.id];
            [[(DepartureCell*)cell _picto] setImage:picto];
            NSString* libDelai = [NSString stringWithFormat:@"%i", (int)(depart._delai/60)];
            [[(DepartureCell*)cell _delai] setText:libDelai];
            [[(DepartureCell*)cell _heure] setText:[_timeIntervalFormatter stringFromDate:[depart _heure]]];
        }
    }
    else {
        // no departure row
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoDepartureCell" forIndexPath:indexPath];

        if (indexPath.row != 0) {
            [[(NoDepartureCell*)cell _message] setText:nil];
        }
    }
    return cell;
}

#pragma mark - Segues
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addFavorite"]) {
        FavoritesNavigationController* controller = (FavoritesNavigationController*)[segue destinationViewController];
        controller.favoritesManager = self.favoritesManager;
        controller.staticDataManager = self.staticDataManager;
        controller.groupManager = self.groupManager;
    }
}

@end
