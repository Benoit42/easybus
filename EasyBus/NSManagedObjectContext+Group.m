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
- (NSArray*) allGroups {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"fetchAllGroups" substitutionVariables:@{}];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"isNearStopGroup" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
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

- (NSArray*) favoriteGroups {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestFromTemplateWithName:@"fetchFavoriteGroups" substitutionVariables:@{}];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
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

- (Group*) nearStopGroup {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"fetchNearStopGroup"];
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

    return (fetchResults.count > 0)?fetchResults[0]:nil;
}

- (Group*) addGroupWithName:(NSString*)name isNearStopGroup:(BOOL)isNearStopGroup {
    // Create and configure a new instance of the Group entity.
    Group* group = (Group*)[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self];
    group.name =  name;
    group.isNearStopGroup = [NSNumber numberWithBool:isNearStopGroup];

    //Retour
    return group;
}

@end
