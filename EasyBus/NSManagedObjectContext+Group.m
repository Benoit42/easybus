//
//  NSManagedObjectContext+Group.m
//  EasyBus
//
//  Created by Benoît on 12/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import "NSManagedObjectContext+Group.h"

@implementation NSManagedObjectContext (Group)

#pragma mark - Model
- (NSManagedObjectModel*)managedObjectModel {
    return self.persistentStoreCoordinator.managedObjectModel;
}

#pragma mark - Manage groupes
- (NSArray*) groups {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    
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

- (Group*) addGroupWithName:(NSString*)name {
    // Create and configure a new instance of the Group entity.
    Group* group = (Group*)[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self];
    group.name =  name;
    
    //Retour
    return group;
}

@end
