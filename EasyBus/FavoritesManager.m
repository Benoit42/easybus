//
//  FavoritesManager.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "FavoritesManager.h"
#import "GroupManager.h"
#import "Stop.h"
#import "Route+RouteWithAdditions.h"

@implementation FavoritesManager
objection_register_singleton(FavoritesManager)

objection_requires(@"managedObjectContext")
@synthesize managedObjectContext;

//Déclaration des notifications
NSString *const updateFavorites = @"updateFavorites";

#pragma manage favorites
- (NSArray*) favorites {
    NSManagedObjectModel *managedObjectModel = [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest *request = [managedObjectModel fetchRequestTemplateForName:@"fetchAllFavorites"];

    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (mutableFetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"route.id" ascending:YES];
    [mutableFetchResults sortUsingDescriptors:@[sortDescriptor]];
    
    return mutableFetchResults;
}

- (Favorite*) favoriteForRoute:(Route*)route stop:(Stop*)stop direction:(NSString*)direction {    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorite"];
    request.predicate = [NSPredicate predicateWithFormat:@"route.id = %@ AND stop.id = %@ AND direction = %@", route.id, stop.id, direction];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"route.id" ascending:YES]];

    NSError *error = nil;
    NSMutableArray *result = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if ([result count] > 0) {
        //Should be 0 or 1 item
        return [result objectAtIndex:0];
    }
    return nil;
}

- (void) addFavorite:(Route*)route stop:(Stop*)stop direction:(NSString*)direction {
    //Recherche du favori
    Favorite* existing = [self favoriteForRoute:route stop:stop direction:direction];
    
    if (existing == nil) {
        // Create and configure a new instance of the Favorite entity.
        Favorite* newFavorite = (Favorite *)[NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:self.managedObjectContext];
        newFavorite.route =  route;
        newFavorite.stop = stop;
        newFavorite.direction = direction;

        // Also create a new group and assign favorite to it
        Group* newGroup = (Group *)[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
        newGroup.name =  newFavorite.stop.name;
        newGroup.terminus = newFavorite.terminus;        
        [newGroup addFavoritesObject:newFavorite];
        
        //Sauvegarde
        NSError* error;
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Error while saving data in main context : %@", error.description);
        }
        
        //Post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:updateFavorites object:self];
    }
}

- (void) removeFavorite:(Favorite*)favorite {
    //Recherche du groupe
    Group* group = favorite.group;
    [group removeFavoritesObject:favorite];
    
    //Suppression du favori
    [self.managedObjectContext deleteObject:favorite];    

    //Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:updateFavorites object:self];
}

- (void) moveFavorite:(Favorite*)favorite fromGroup:(Group*)sourceGroup toGroup:(Group*)destinationGroup atIndex:(NSUInteger)index {
    [sourceGroup removeFavoritesObject:favorite];
    [destinationGroup insertObject:favorite inFavoritesAtIndex:index];

    //Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:updateFavorites object:self];
}

@end
