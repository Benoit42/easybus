//
//  FlipsideViewController.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "LinesViewController.h"
#import "LinesNavigationController.h"
#import "LineCell.h"
#import "Route+Additions.h"
#import "NSManagedObjectContext+Network.h"
#import "NSManagedObjectContext+Trip.h"
#import "NSManagedObjectContext+Group.h"

@implementation LinesViewController
objection_requires( @"managedObjectContext", @"gtfsDownloadManager")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
    NSParameterAssert(self.gtfsDownloadManager != nil);
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.managedObjectContext.trips.count == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Favoris" message:@"Choisissez une ligne, un arrêt et une direction, puis appuyez sur 'Sauver'" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.managedObjectContext routes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* routes = [self.managedObjectContext sortedRoutes];
    
    //get routes section
    if (indexPath.row < [routes count]) {
        static NSString *CellIdentifier = @"Cell";
        LineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //get route
        Route* route = [routes objectAtIndex:indexPath.row];
        
        //add departure
        [cell._picto setImage:[UIImage imageNamed:route.id]];
        [cell.libTerminus0 setText:[route terminusForDirection:@"0"]];
        [cell.libTerminus1 setText:[route terminusForDirection:@"1"]];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //get route
    Route* route = [[self.managedObjectContext sortedRoutes] objectAtIndex:indexPath.row];

    //get the current trip from nav controler and update it
    ((LinesNavigationController*)self.navigationController).currentTripRoute = route;
}

#pragma mark ajout du trip
- (IBAction)unwindFromSave:(UIStoryboardSegue *)segue {
    //Get data
    Route* route = ((LinesNavigationController*)self.navigationController).currentTripRoute;
    Stop* stop = ((LinesNavigationController*)self.navigationController).currentTripStop;
    NSString* direction = ((LinesNavigationController*)self.navigationController).currentTripDirection;

    //Create the trip
    Trip* trip = [self.managedObjectContext addTrip:route stop:stop direction:direction];

    //Create the group and add the trip
    NSString* groupName = [NSString stringWithFormat:@"vers %@", [route terminusForDirection:direction]];
    Group* group = [self.managedObjectContext addGroupWithName:groupName isNearStopGroup:NO];
    [group addTripsObject:trip];
    
    //Sauvegarde
    NSError* error;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error while saving data in main context : %@", error.description);
    }
}

@end
