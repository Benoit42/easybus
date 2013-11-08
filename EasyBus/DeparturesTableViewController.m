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

objection_requires(@"favoritesManager", @"groupManager", @"departuresManager", @"staticDataManager")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
    refreshLabelFont = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
}

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Pré-conditions
    NSAssert(self.favoritesManager != nil, @"favoritesManager should not be nil");
    NSAssert(self.groupManager != nil, @"groupManager should not be nil");
    NSAssert(self.departuresManager != nil, @"departuresManager should not be nil");
    NSAssert(self.staticDataManager != nil, @"staticDataManager should not be nil");
    
    // Instanciates des data
    self.timeIntervalFormatter = [[NSDateFormatter alloc] init];
    self.timeIntervalFormatter.timeStyle = NSDateFormatterFullStyle;
    self.timeIntervalFormatter.dateFormat = @"HH:mm";
    
    //check resolution
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 480) {
        self.maxRows = 4;
    }
    else {
        self.maxRows = 5;
    }
    
    // Abonnement au notifications des départs
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedStarted:) name:departuresUpdateStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdatedSucceeded:) name:departuresUpdateSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departuresUpdateFailed:) name:departuresUpdateFailed object:nil];
    
    //Pull to refresh
    self.refreshControl  = [[UIRefreshControl alloc] init];

    NSString* message = @"tirer pour raffraîchir";
    NSMutableAttributedString *attributedMessage=[[NSMutableAttributedString alloc] initWithString:message];
    [attributedMessage addAttribute:NSFontAttributeName value:refreshLabelFont range:NSMakeRange(0, [message length])];
    self.refreshControl.attributedTitle = attributedMessage;

    [self.refreshControl  addTarget:nil action:@selector(refreshDepartures) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Gestion de la mise à jour des départs
- (void)departuresUpdatedStarted:(NSNotification *)notification {
    // stop indicator
    [self.refreshControl endRefreshing];
    
    //message
    NSString* message = @"mise à jour en cours...";
    NSMutableAttributedString *attributedMessage=[[NSMutableAttributedString alloc] initWithString:message];
    [attributedMessage addAttribute:NSFontAttributeName value:refreshLabelFont range:NSMakeRange(0, [message length])];
    self.refreshControl.attributedTitle = attributedMessage;
}

#pragma mark - Stuff for refreshing view
- (void)departuresUpdatedSucceeded:(NSNotification *)notification {
    // stop indicator
    [self.refreshControl endRefreshing];
    
    //message
    NSString* date = [_timeIntervalFormatter stringFromDate:self.departuresManager._refreshDate];
    NSString* message = [NSString stringWithFormat:@"mis à jour à %@", date];

    NSMutableAttributedString *attributedMessage=[[NSMutableAttributedString alloc] initWithString:message];
    [attributedMessage addAttribute:NSFontAttributeName value:refreshLabelFont range:NSMakeRange(0, [message length])];
    self.refreshControl.attributedTitle = attributedMessage;
    
    //refresh table view
    [self.tableView reloadData];
}

- (void)departuresUpdateFailed:(NSNotification *)notification {
    // stop indicator
    [self.refreshControl endRefreshing];
    
    //message
    NSString* message = @"échec de la mise à jour";
    NSMutableAttributedString *attributedMessage=[[NSMutableAttributedString alloc] initWithString:message];
    [attributedMessage addAttribute:NSFontAttributeName value:refreshLabelFont range:NSMakeRange(0, [message length])];
    self.refreshControl.attributedTitle = attributedMessage;
}

#pragma mark - Table view refresh control
- (void) refreshDepartures {
    [self.departuresManager refreshDepartures:[self.favoritesManager favorites]];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section plus header and footer
    // always header + footer + iphone5->5, other->4
    NSArray* groupes = [self.groupManager groups];
    NSInteger page = ((DeparturesViewController*)self.parentViewController).page;
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
    NSInteger page = ((DeparturesViewController*)self.parentViewController).page;
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
            NSURL* picto = [self.staticDataManager pictoUrl100ForRouteId:depart.route];
            [[(DepartureCell*)cell _picto] setImageWithURL:picto];
            NSString* libDelai = [NSString stringWithFormat:@"%i", (int)(depart._delai/60)];
            [[(DepartureCell*)cell _delai] setText:libDelai];
            [[(DepartureCell*)cell _delai] setTextColor:depart.isRealTime?Constants.starGreenColor:UIColor.blackColor];
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

@end
