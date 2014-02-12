//
//  NSManagedObjectContext+Group.m
//  EasyBus
//
//  Created by Benoît on 12/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import "NSManagedObjectContext+Group.h"

@implementation NSManagedObjectContext (Group)

//Déclaration des notifications
NSString *const updateGroups = @"updateGroups";

#pragma mark - Model
- (NSManagedObjectModel*)managedObjectModel {
    return self.persistentStoreCoordinator.managedObjectModel;
}

#pragma mark - Manage groupes
- (NSArray*) groups {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"terminus" ascending:YES]];
    
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
    
    return fetchResults;
}

- (void) addGroupWithName:(NSString*)name andTerminus:(NSString*)terminus {
    // Create and configure a new instance of the Favorite entity.
    Group* newGroupe = (Group*)[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self];
    newGroupe.name =  name;
    newGroupe.terminus = terminus;
    
}

- (void) removeGroup:(Group*)group {
    //Suppression du groupe
    [self deleteObject:group];
}

@end
