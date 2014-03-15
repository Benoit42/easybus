//
//  DeparturesTableViewController.m
//  EasyBus
//
//  Created by Benoit on 11/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "DeparturesTableViewController.h"
#import "Constants.h"
#import "DeparturesTableViewController.h"
#import "DepartureCell.h"
#import "NoDepartureCell.h"
#import "NSManagedObjectContext+Trip.h"
#import "Route+Additions.h"
#import "DeparturesNavigationController.h"

@interface DeparturesTableViewController()

@property(nonatomic) NSDateFormatter* timeIntervalFormatter;

@end

@implementation DeparturesTableViewController {
    UIFont* refreshLabelFont;
}
objection_requires(@"managedObjectContext", @"departuresManager", @"locationManager")
#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext);
    NSParameterAssert(self.departuresManager);
    NSParameterAssert(self.locationManager);
    
    // Instanciates des data
    self.timeIntervalFormatter = [[NSDateFormatter alloc] init];
    self.timeIntervalFormatter.timeStyle = NSDateFormatterFullStyle;
    self.timeIntervalFormatter.dateFormat = @"HH:mm";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //Pré-conditions
    NSParameterAssert(self.group);

    //update header
    [self.navigationItem setTitle:self.group.name];

    // Abonnement au notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedSucceeded:) name:departuresUpdateSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdateFailed:) name:departuresUpdateFailedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Fermeture du pull to refresh
    [self performBlockOnMainThread:^{
        [self.refreshControl endRefreshing];
    }];

    //Désabonnement aux notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Stuff for refreshing view
- (void)departuresUpdatedSucceeded:(NSNotification *)notification {
    [self performBlockOnMainThread:^{
        //refresh table view
        [self.navigationItem setTitle:self.group.name];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)departuresUpdateFailed:(NSNotification *)notification {
    [self performBlockOnMainThread:^{
        // stop indicator
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Table view refresh control
- (IBAction)refreshAsked:(id)sender {
    NSLog(@"Refresh asked");
    [self.departuresManager refreshDepartures];
    [self.locationManager updateLocation];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section
    // If no departures, still 1 row to indicate no departures
#warning voir si on peut définir une méthode abstarite trips sur l'entité Group
    NSArray* trips = [((FavoriteGroup*)self.group).trips allObjects];
    NSArray* departures = [self.departuresManager getDeparturesForTrips:trips];
    NSInteger count = MAX(departures.count, 1);
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //create cell
    UITableViewCell* cell;
    
    //get departures
#warning voir si on peut définir une méthode abstarite trips sur l'entité Group
    NSArray* trips = [((FavoriteGroup*)self.group).trips allObjects];
    NSArray* departures = [self.departuresManager getDeparturesForTrips:trips];
    if (indexPath.row < [departures count]) {
        // departure row
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        //get departure
        Depart* depart = [departures objectAtIndex:indexPath.row];
        
        //update cell
        [[(DepartureCell*)cell _picto] setImage:[UIImage imageNamed:depart.route.id]];
        NSString* libDelai = [NSString stringWithFormat:@"%i", (int)(depart._delai/60)];
        [[(DepartureCell*)cell _delai] setText:libDelai];
        [[(DepartureCell*)cell _delai] setTextColor:depart.isRealTime?Constants.starGreenColor:UIColor.blackColor];
        [[(DepartureCell*)cell _heure] setText:[_timeIntervalFormatter stringFromDate:[depart _heure]]];
        [[(DepartureCell*)cell direction] setText:[depart.route terminusForDirection:depart._direction] ];
    }
    else {
        // no departure row
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoDepartureCell" forIndexPath:indexPath];
        
        if (indexPath.row != 0) {
            [[(NoDepartureCell*)cell _message] setText:nil];
        }
    }

    //Retour
    return cell;
}

@end
