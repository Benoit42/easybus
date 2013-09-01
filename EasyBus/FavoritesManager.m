//
//  FavoritesManager.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "FavoritesManager.h"
#import "Stop.h"
#import "Route+RouteWithAdditions.h"

@interface FavoritesManager()

@property (nonatomic, retain, readonly) NSManagedObjectContext *_managedObjectContext;

@end

@implementation FavoritesManager

@synthesize _managedObjectContext;

//constructeur
- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext {
    if ( self = [super init] ) {
        _managedObjectContext = managedObjectContext;
    }
    return self;
}

#pragma manage favorites
- (NSArray*) favorites {
    NSManagedObjectModel *managedObjectModel = [[_managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSFetchRequest *request = [managedObjectModel fetchRequestTemplateForName:@"fetchAllFavorites"];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
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
    NSMutableArray *result = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
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
        Favorite* newFavorite = (Favorite *)[NSEntityDescription insertNewObjectForEntityForName:@"Favorite" inManagedObjectContext:_managedObjectContext];
        newFavorite.route =  route;
        newFavorite.stop = stop;
        newFavorite.direction = direction;
    
        NSError *error = nil;
        if (![_managedObjectContext save:&error]) {
            //Log
            NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
        }
    }
}

- (void) removeFavorite:(Favorite*)favorite {
    //Suppression du favori
    [_managedObjectContext deleteObject:favorite];
        
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
}

- (NSArray*) groupes {
    //retourne la liste des groupes de favoris (stopId+terminus)
    //Remarque : pour économiser l'écriture d'une classe, on utilise un objet Favori pour représenter un Groupe
    //Principe : on retourne pour chaque paire stopId/terminus, un seul favori correspondant
    //Remarque : modèle vraiment pourri :-(

    //Recherche des paires uniques stopId/direction
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Favorite"];

    NSError *error = nil;
    NSArray * favorites = [_managedObjectContext executeFetchRequest:request error:&error];
    if (favorites == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    
    //Suppression des doublons stopId/terminus
    NSMutableDictionary* groupes = [NSMutableDictionary new];
    for (Favorite* favorite in favorites) {
        [groupes setObject:favorite forKey:[NSString stringWithFormat:@"%@-%@", favorite.stop.name, favorite.terminus]];
    }
    
    return [groupes allValues];
}

- (NSArray*) favoritesForGroupe:(Favorite*)groupe {
    //retourne la liste des favoris pour un arrêt et un terminus
    //Remarque : pour économiser l'écriture d'une classe, on utilise un objet Favori pour représenter un Groupe
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stop.id == %@ && terminus == %@", groupe.stop.name, groupe.terminus];
    return [[self favorites] filteredArrayUsingPredicate:predicate];
}

#pragma manage notifications
- (void) sendUpdateNotification {
    //lance la notification favoritesUpdated
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavorites" object:self];
}

@end
