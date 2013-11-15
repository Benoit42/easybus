//
//  DeparturesTableViewController.m
//  EasyBus
//
//  Created by Benoit on 11/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "NSObject+AsyncPerformBlock.h"
#import "DeparturesTableViewController.h"
#import "Constants.h"
#import "DeparturesViewController.h"
#import "DepartureCell.h"
#import "NoDepartureCell.h"

@interface DeparturesTableViewController()

@property(nonatomic) NSDateFormatter* timeIntervalFormatter;
@property(nonatomic) NSUInteger maxRows;
@property(nonatomic) NSDate* _lastRefresh;

@end

@implementation DeparturesTableViewController {
    UIFont* refreshLabelFont;
}

objection_requires(@"departuresManager")
//objection_initializer(initWithMake:model:)

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
    refreshLabelFont = [UIFont fontWithName:@"Heiti TC" size:15.0f];
}

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Pré-conditions
    NSParameterAssert(self.group != nil);
    NSParameterAssert(self.departuresManager != nil);
    
    // Instanciates des data
    self.timeIntervalFormatter = [[NSDateFormatter alloc] init];
    self.timeIntervalFormatter.timeStyle = NSDateFormatterFullStyle;
    self.timeIntervalFormatter.dateFormat = @"HH:mm";
    
    // Abonnement au notifications des départs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedStarted:) name:departuresUpdateStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedSucceeded:) name:departuresUpdateSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdateFailed:) name:departuresUpdateFailed object:nil];
    
    //Pull to refresh
    UIRefreshControl* refreshControl  = [[UIRefreshControl alloc] init];

    NSString* message = @"tirer pour raffraîchir";
    NSMutableAttributedString *attributedMessage=[[NSMutableAttributedString alloc] initWithString:message];
    [attributedMessage addAttribute:NSFontAttributeName value:refreshLabelFont range:NSMakeRange(0, [message length])];
    refreshControl.attributedTitle = attributedMessage;
    refreshControl.backgroundColor = [Constants veryLightGreyColor];
    [refreshControl  addTarget:nil action:@selector(refreshDepartures) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

#pragma mark - Gestion de la mise à jour des départs
- (void)departuresUpdatedStarted:(NSNotification *)notification {
    [self performBlockOnMainThread:^{
        //message
        NSString* message = @"mise à jour en cours...";
        NSMutableAttributedString *attributedMessage=[[NSMutableAttributedString alloc] initWithString:message];
        [attributedMessage addAttribute:NSFontAttributeName value:refreshLabelFont range:NSMakeRange(0, [message length])];
        self.refreshControl.attributedTitle = attributedMessage;
    }];
}

#pragma mark - Stuff for refreshing view
- (void)departuresUpdatedSucceeded:(NSNotification *)notification {
    [self performBlockOnMainThread:^{
        // stop indicator
        [self.refreshControl endRefreshing];
        
        //message
        NSString* date = [_timeIntervalFormatter stringFromDate:self.departuresManager._refreshDate];
        NSString* message = date?[NSString stringWithFormat:@"mis à jour à %@", date]:@"tirer pour raffraîchir";

        NSMutableAttributedString *attributedMessage=[[NSMutableAttributedString alloc] initWithString:message];
        [attributedMessage addAttribute:NSFontAttributeName value:refreshLabelFont range:NSMakeRange(0, [message length])];
        self.refreshControl.attributedTitle = attributedMessage;
        
        //refresh table view
        [self.tableView reloadData];
    }];
}

- (void)departuresUpdateFailed:(NSNotification *)notification {
    [self performBlockOnMainThread:^{
        // stop indicator
        [self.refreshControl endRefreshing];
        
        //message
        NSString* message = @"échec de la mise à jour";
        NSMutableAttributedString *attributedMessage=[[NSMutableAttributedString alloc] initWithString:message];
        [attributedMessage addAttribute:NSFontAttributeName value:refreshLabelFont range:NSMakeRange(0, [message length])];
        self.refreshControl.attributedTitle = attributedMessage;
    }];
}

#pragma mark - Table view refresh control
- (void) refreshDepartures {
    [self performBlockInBackground:^{
        [self.departuresManager refreshDepartures:self.group.favorites.array];
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section
    // If no departures, still 1 row to indicate no departures
    NSArray* departures = [self.departuresManager getDeparturesForGroupe:self.group];
    return MAX(departures.count, 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //create cell
    UITableViewCell* cell;
    
    //get departures
    NSArray* departures = [self.departuresManager getDeparturesForGroupe:self.group];
    if (indexPath.row < [departures count] ){
        // departure row
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        //get departure
        Depart* depart = [departures objectAtIndex:indexPath.row];
        
        //update cell
        [[(DepartureCell*)cell _picto] setImageWithURL:depart.route.pictoUrl];
        NSString* libDelai = [NSString stringWithFormat:@"%i", (int)(depart._delai/60)];
        [[(DepartureCell*)cell _delai] setText:libDelai];
        [[(DepartureCell*)cell _delai] setTextColor:depart.isRealTime?Constants.starGreenColor:UIColor.blackColor];
        [[(DepartureCell*)cell _heure] setText:[_timeIntervalFormatter stringFromDate:[depart _heure]]];
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
