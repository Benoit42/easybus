//
//  IoCModule.m
//  EasyBus
//
//  Created by Benoit on 28/09/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CoreData/CoreData.h>

@interface IoCModuleTest : JSObjectionModule

@end

@implementation IoCModuleTest

- (void)configure {
    //Instanciation du contexte CoreData
    //Initialize context
    NSManagedObjectModel* managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:0];
    NSManagedObjectContext* managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: persistentStoreCoordinator];
    
    [self bind:managedObjectModel toClass:[NSManagedObjectModel class]];
    [self bind:managedObjectContext toClass:[NSManagedObjectContext class]];
}

@end
