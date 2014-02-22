//
//  StopsViewControler.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "NSObject+AsyncPerformBlock.h"
#import "NearStopsViewController.h"
#import "NearStopsNavigationController.h"
#import "LinesNavigationController.h"
#import "StopCell.h"
#import "NSManagedObjectContext+Network.h"
#import "DeparturesTableViewController.h"
#import "NSManagedObjectContext+Group.h"
#import "NSManagedObjectContext+Trip.h"
#import "Route.h"

@interface NearStopsViewController()

@property (nonatomic) NSArray* stops;

@end

@implementation NearStopsViewController
objection_requires(@"managedObjectContext", @"departuresManager", @"locationManager")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
    
    NSParameterAssert(self.managedObjectContext);
    NSParameterAssert(self.departuresManager);
    NSParameterAssert(self.locationManager);
}

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
}

- (void)viewWillAppear:(BOOL)animated {
    //Raffraichissement de la localisation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated:) name:locationFoundNotification object:nil];
    [self refreshLocation:nil];
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


#pragma mark - UItableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Show only one line as we aggregate a stops having same name
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Get nearest stops having same name
    CLLocation* here = [self.locationManager currentLocation];
    self.stops = [self.managedObjectContext nearestStopsHavingSameNameFrom:here];

    //get departure section
    if (indexPath.row < [self.stops count]) {
        //get the stop
        Stop* stop = [self.stops objectAtIndex:indexPath.row];
        
        static NSString *CellIdentifier = @"Cell";
        StopCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //add departure
        [cell._libArret setText:stop.name];
        return cell;
    }
    return nil;
}

#pragma mark - Refresh
- (IBAction)refreshLocation:(id)sender {
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"departuresView"]) {
        //Create group/trip
        NSMutableArray* trips = [[NSMutableArray alloc] init];
        [self.stops enumerateObjectsUsingBlock:^(Stop* selectedStop, NSUInteger idx, BOOL *stop) {
            [selectedStop.routesDirectionZero enumerateObjectsUsingBlock:^(Route* route, NSUInteger idx, BOOL *stop) {
                Trip* trip = [self.managedObjectContext addTrip:route stop:selectedStop direction:@"0"];
                [trips addObject:trip];
            }];
            [selectedStop.routesDirectionOne enumerateObjectsUsingBlock:^(Route* route, NSUInteger idx, BOOL *stop) {
                Trip* trip = [self.managedObjectContext addTrip:route stop:selectedStop direction:@"1"];
                [trips addObject:trip];
            }];
            
            NSError *error = nil;
            if (![self.managedObjectContext save:&error]) {
                //Log
                NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
            }
        }];

        ((DeparturesTableViewController*)segue.destinationViewController).trips = trips;
        ((DeparturesTableViewController*)segue.destinationViewController).title = @"à proximité";
        [self.departuresManager refreshDepartures:trips];
    }
}

#pragma mark - notifications
- (void)locationUpdated:(NSNotification*)notif {
    [self performBlockOnMainThread:^{
        //rechargement de la vue
        [self.tableView reloadData];

        //Fermeture du pull to refresh
        [self.refreshControl endRefreshing];
    }];
}

@end
