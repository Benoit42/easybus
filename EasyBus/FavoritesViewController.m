//
//  FavoritesViewController.m
//  EasyBus
//
//  Created by Benoit on 13/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "FavoritesViewController.h"
#import "LinesViewController.h"
#import "Trip+Additions.h"
#import "Route+Additions.h"
#import "Stop.h"
#import "FavoriteCell.h"
#import "NSManagedObjectContext+Trip.h"
#import "NSManagedObjectContext+Group.h"

#define FAVORITE_CACHE_NAME @"FavoritesCache"

@interface FavoritesViewController() <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) BOOL changeIsUserDriven;

@end

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
    self.changeIsUserDriven = NO;

    //Create fetchedResultsController
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Trip" inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"favoriteGroup != nil"]];
    [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"favoriteGroup.name" ascending:YES], [[NSSortDescriptor alloc] initWithKey:@"route.id" ascending:YES]]];
    [fetchRequest setFetchBatchSize:20];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:@"favoriteGroup.objectID"
                                                                                   cacheName:FAVORITE_CACHE_NAME];
    self.fetchedResultsController.delegate = self;
    

    //Perform fetch
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Error %@, %@", error, [error userInfo]);
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    //Désactivation du mode édition
    if (self.tableView.isEditing) {
        [self.tableView setEditing:NO animated:YES];
        [self.modifyButton setTitle:@"modifier"];
    }
}

#pragma mark - UItableViewDatasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSArray* sections = [self.fetchedResultsController sections];
    NSUInteger count = [sections count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSUInteger count = 0;
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        count =  [sectionInfo numberOfObjects];
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    Trip* trip = (Trip*)[sectionInfo objects][0];
    FavoriteGroup* group = trip.favoriteGroup;
    NSString* groupName = group.name;
    return groupName;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //Get trip
    Trip *trip = [self.fetchedResultsController objectAtIndexPath:indexPath];

    //Configure cell
    FavoriteCell* favoriteCell = (FavoriteCell*)cell;
    [favoriteCell._picto setImage:[UIImage imageNamed:trip.route.id]];
    [favoriteCell._libArret setText:trip.stop.name];
    [favoriteCell._libDirection setText:[trip.route terminusForDirection:trip.direction]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Get cell
    FavoriteCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Delete trip
        Trip *trip = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:trip];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    //Refuse to move a row inside a section
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        return proposedDestinationIndexPath;
    }
    else {
        return  sourceIndexPath;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    //Get trip and source group
    Trip *trip = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
    FavoriteGroup* sourceGroup = trip.favoriteGroup;

    //Get destination group
    id<NSFetchedResultsSectionInfo> destinationSectionInfo = [[self.fetchedResultsController sections] objectAtIndex:destinationIndexPath.section];
    Trip* destinationTrip = (Trip*)[destinationSectionInfo objects][0];
    FavoriteGroup* destinationGroup = destinationTrip.favoriteGroup;

    //Move trip
    trip.favoriteGroup = destinationGroup;

    //Move flag
    self.changeIsUserDriven = YES;
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            if (!self.changeIsUserDriven) {
                self.changeIsUserDriven = NO;
                [tableView deleteRowsAtIndexPaths:[NSArray
                                                   arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray
                                                   arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - Manages interactions
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (!self.tableView.isEditing) {
        [self.tableView setEditing:YES animated:YES];
        [self.modifyButton setTitle:@"fin"];
    }
}

- (IBAction)modifyButtonPressed:(id)sender {
    if (self.tableView.isEditing) {
        //fin de l'édition
        [self.tableView setEditing:NO animated:YES];
        [self.modifyButton setTitle:@"modifier"];
    }
    else {
        [self.tableView setEditing:YES animated:YES];
        [self.modifyButton setTitle:@"fin"];
    }
}

#pragma mark - model
- (NSManagedObjectModel*)managedObjectModel {
    return self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
}

@end
