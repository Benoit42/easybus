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
//TODO: Possible de mettre un template
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

- (Favorite*) addFavorite:(Route*)route stop:(Stop*)stop direction:(NSString*)direction {
    //Recherche du favori
#warning Pas forcément utile de checker le doublon
    Favorite* favorite = [self favoriteForRoute:route stop:stop direction:direction];
    
    if (favorite == nil) {
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
    }
    
    //Retour
    return favorite;
}

- (void) moveFavorite:(Favorite*)favorite fromGroup:(Group*)sourceGroup toGroup:(Group*)destinationGroup atIndex:(NSUInteger)index {
    [sourceGroup removeFavoritesObject:favorite];
    [destinationGroup insertObject:favorite inFavoritesAtIndex:index];
}

@end
