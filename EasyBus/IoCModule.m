//
//  IoCModule.m
//  EasyBus
//
//  Created by Benoit on 28/09/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "IoCModule.h"

@implementation IoCModule

- (void)configure {
    //Instanciation du contexte CoreData
    NSManagedObjectModel* managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    [self bind:managedObjectModel toClass:[NSManagedObjectModel class]];
    
    NSPersistentStoreCoordinator* persistentStoreCoordinator = [self getPersistentStoreCoordinatorForModel:managedObjectModel];
    
    NSManagedObjectContext* managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: persistentStoreCoordinator];
    [self bind:managedObjectContext toClass:[NSManagedObjectContext class]];
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)getPersistentStoreCoordinatorForModel:(NSManagedObjectModel*)managedObjectModel {
    NSPersistentStoreCoordinator* persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"data.sqlite"]];
    //[[NSFileManager defaultManager] removeItemAtURL:storeUrl error:NULL];
	NSError *error;
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
        [[NSFileManager defaultManager] removeItemAtURL:storeUrl error:NULL];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Erreur" message:@"Erreur lors du chargement, effacement des données" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
	
    return persistentStoreCoordinator;
}

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
