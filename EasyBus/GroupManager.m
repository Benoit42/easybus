//
//  FavoritesManager.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "GroupManager.h"

@implementation GroupManager
objection_register_singleton(GroupManager)

objection_requires(@"managedObjectContext")
@synthesize managedObjectContext;

#pragma manage groupes
- (NSArray*) groups {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"terminus" ascending:YES]];
    
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
    
    return mutableFetchResults;
}

- (void) addGroupWithName:(NSString*)name andTerminus:(NSString*)terminus {
    // Create and configure a new instance of the Favorite entity.
    Group* newGroupe = (Group*)[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
    newGroupe.name =  name;
    newGroupe.terminus = terminus;

    //sauvegarde du contexte
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
}

- (void) removeGroup:(Group*)group {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    //Suppression du groupe
    [self.managedObjectContext deleteObject:group];

    //sauvegarde du contexte
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
}

#pragma manage notifications
- (void) sendUpdateNotification {
    //lance la notification favoritesUpdated
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateGroups" object:self];
}

@end
