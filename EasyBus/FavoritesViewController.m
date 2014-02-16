//
//  FavoritesViewController.m
//  EasyBus
//
//  Created by Benoit on 13/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "NSObject+AsyncPerformBlock.h"
#import "FavoritesViewController.h"
#import "LinesViewController.h"
#import "Trip.h"
#import "Route+Additions.h"
#import "Stop.h"
#import "FavoriteCell.h"
#import "NSManagedObjectContext+Trip.h"
#import "NSManagedObjectContext+Group.h"

@implementation FavoritesViewController
objection_requires(@"managedObjectContext")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);

    //Ajout long press gesture
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //Désactivation du mode édition
    if (self.tableView.isEditing) {
        [self.tableView setEditing:NO animated:YES];
        [self.modifyButton setTitle:@"modifier"];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSUInteger count = [[self.managedObjectContext groups] count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    Group* group = [[self.managedObjectContext groups] objectAtIndex:section];
    NSUInteger count = [group.trips count];
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section < [[self.managedObjectContext groups] count]) {
        Group* group = [[self.managedObjectContext groups] objectAtIndex:section];
        
        //add departure
        return group.name;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Get trips
    Group* group = [[self.managedObjectContext groups] objectAtIndex:indexPath.section];
    NSOrderedSet* trips = group.trips;
    
    //get departure section
    if (indexPath.row < trips.count) {
        static NSString *CellIdentifier = @"Cell";
        FavoriteCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //get the trip
        Trip* trip = [trips objectAtIndex:indexPath.row];

        //add departure
        [cell._picto setImage:[UIImage imageNamed:trip.route.id]];
        [cell._libArret setText:trip.stop.name];
        [cell._libDirection setText:[trip.route terminusForDirection:trip.direction]];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //begin editing update
        [self.tableView beginUpdates];
        
        // delete your data item here
        Group* group = [[self.managedObjectContext groups] objectAtIndex:indexPath.section];
        Trip* trip = [[group trips] objectAtIndex:indexPath.row];
        [self.managedObjectContext deleteObject:trip];
        trip.group = nil;
        
        // Animate the deletion from the table
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        if (group.trips.count == 0) {
            [self.managedObjectContext deleteObject:group];
            NSIndexSet *sections = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(indexPath.section, 1)];
            [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
        }

        //end editing update
        [self.tableView endUpdates];
    }

    //Sauvegarde
    NSError* error;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error while saving data in main context : %@", error.description);
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //Get source group
    Group* sourceGroup = [[self.managedObjectContext groups] objectAtIndex:sourceIndexPath.section];
    
    //Get favorite
    Trip* trip = [[sourceGroup trips] objectAtIndex:sourceIndexPath.row];

    //Get destination group
    Group* destinationGroup = [[self.managedObjectContext groups] objectAtIndex:destinationIndexPath.section];

    //Move favorite
    [self.managedObjectContext moveTrip:trip fromGroup:sourceGroup toGroup:destinationGroup atIndex:destinationIndexPath.row];

#warning pourquoi le dispatch_async ?
    if (sourceGroup.trips.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.managedObjectContext deleteObject:sourceGroup];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sourceIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        });
    }

    //Sauvegarde
    NSError* error;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"Error while saving data in main context : %@", error.description);
    }    
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (!self.tableView.isEditing) {
        [self.tableView setEditing:YES animated:YES];
        [self.modifyButton setTitle:@"fin"];
    }
}

- (IBAction)modifyButtonPressed:(id)sender {
    if (self.tableView.isEditing) {
        [self.tableView setEditing:NO animated:YES];
        [self.modifyButton setTitle:@"modifier"];
    }
    else {
        [self.tableView setEditing:YES animated:YES];
        [self.modifyButton setTitle:@"fin"];
    }
}

#pragma mark - Segues
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"chooseLine"]) {
        if (self.tableView.isEditing) {
            [self.tableView setEditing:NO animated:YES];
            [self.modifyButton setTitle:@"modifier"];
            return FALSE;
        }
    }
    
    return TRUE;
}

@end
