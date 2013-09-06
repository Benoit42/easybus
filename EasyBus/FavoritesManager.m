//
//  FavoritesManager.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "FavoritesManager.h"
#import "GroupManager.h"
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

        // Also create a new group and assign favorite to it
        Group* newGroup = (Group *)[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:_managedObjectContext];
        newGroup.name =  newFavorite.stop.name;
        newGroup.terminus = newFavorite.terminus;        
        newFavorite.group = newGroup;
    }
}

- (void) removeFavorite:(Favorite*)favorite {
    //Recherche du groupe
    Group* group = favorite.group;
    
    //Suppression du favori
    [_managedObjectContext deleteObject:favorite];
    
    //Suppression du groupe s'il est vide
    if ([group.favorites count] == 0) {
        [_managedObjectContext deleteObject:group];
    }
}

#pragma manage notifications
- (void) sendUpdateNotification {
    //lance la notification favoritesUpdated
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavorites" object:self];
}

@end
