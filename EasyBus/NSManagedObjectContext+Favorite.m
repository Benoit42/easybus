//
//  NSManagedObjectContext+Favorite.m
//  EasyBus
//
//  Created by Benoît on 09/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import "NSManagedObjectContext+Favorite.h"
#import "Favorite+FavoriteWithAdditions.h"

@implementation NSManagedObjectContext (Favorite)

NSString *const updateFavorites = @"updateFavorites";

#pragma mark - Model
- (NSManagedObjectModel*)managedObjectModel {
    return self.persistentStoreCoordinator.managedObjectModel;
}

#pragma - Manage favorites
- (NSArray*) favorites {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"fetchAllFavorites"];
    
    NSError *error = nil;
    NSArray *fetchResults = [self executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (fetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }

#warning Voir impact de la suppression du tri
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
//                                        initWithKey:@"route.id" ascending:YES];
//    [mutableFetchResults sortUsingDescriptors:@[sortDescriptor]];
//    
    return fetchResults;
}

- (Favorite*) favoriteForRoute:(Route*)route stop:(Stop*)stop direction:(NSString*)direction {
#warning Possible de mettre un template
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorite"];
    request.predicate = [NSPredicate predicateWithFormat:@"route.id = %@ AND stop.id = %@ AND direction = %@", route.id, stop.id, direction];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"route.id" ascending:YES]];
    
    NSError *error = nil;
    NSArray *fetchResults = [self executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if ([fetchResults count] > 0) {
        //Should be 0 or 1 item
        return [fetchResults objectAtIndex:0];
    }
    return nil;
}

- (void) addFavorite:(Route*)route stop:(Stop*)stop direction:(NSString*)direction {
    //Recherche du favori
#warning Pas forcément utile de checker le doublon
    Favorite* existing = [self favoriteForRoute:route stop:stop direction:direction];
    
    if (existing == nil) {
        // Create and configure a new instance of the Favorite entity.
        Favorite* newFavorite = (Favorite *)[NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:self];
        newFavorite.route =  route;
        newFavorite.stop = stop;
        newFavorite.direction = direction;
        
        // Also create a new group and assign favorite to it
        Group* newGroup = (Group *)[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self];
        newGroup.name =  newFavorite.stop.name;
        newGroup.terminus = newFavorite.terminus;
        [newGroup addFavoritesObject:newFavorite];
        
        //Post notification
        [[NSNotificationCenter defaultCenter] postNotificationName:updateFavorites object:self];
    }
}

- (void) removeFavorite:(Favorite*)favorite {
#warning Voir à gérer la suppression du groupe au niveau CoreData ?
    //Recherche du groupe
    Group* group = favorite.group;
    [group removeFavoritesObject:favorite];
    
    //Suppression du favori
    [self deleteObject:favorite];
    
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
