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

//Déclaration des notifications
NSString *const updateGroups = @"updateGroups";

#pragma manage groupes
- (NSArray*) groups {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"terminus" ascending:YES]];
    
    NSError *error = nil;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (fetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }
    
    return fetchResults;
}

- (void) addGroupWithName:(NSString*)name andTerminus:(NSString*)terminus {
    // Create and configure a new instance of the Favorite entity.
    Group* newGroupe = (Group*)[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
    newGroupe.name =  name;
    newGroupe.terminus = terminus;

}

- (void) removeGroup:(Group*)group {
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
    
    //Suppression du groupe
    [self.managedObjectContext deleteObject:group];
}

#pragma manage notifications
- (void) sendUpdateNotification {
    //lance la notification favoritesUpdated
    [[NSNotificationCenter defaultCenter] postNotificationName:updateGroups object:self];
}

@end
