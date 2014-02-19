//
//  StopsViewControler.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return 3 stops
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get stop list
    CLLocation* here = [self.locationManager currentLocation];
    self.stops = [self.managedObjectContext stopsSortedByDistanceFrom:here];
    
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

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"departuresView"]) {
        //Create group/trip
        Stop* selectedStop = self.stops[self.tableView.indexPathForSelectedRow.row];
        NSMutableArray* trips = [[NSMutableArray alloc] init];
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

        ((DeparturesTableViewController*)segue.destinationViewController).trips = trips;
        ((DeparturesTableViewController*)segue.destinationViewController).title = @"à proximité";
        [self.departuresManager refreshDepartures:trips];
    }
}

@end
