//
//  FavoritesManager.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "GroupManager.h"

@interface GroupManager()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation GroupManager

@synthesize managedObjectContext;

//constructeur
- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext_ {
    if ( self = [super init] ) {
        self.managedObjectContext = managedObjectContext_;
    }
    return self;
}

#pragma manage groupes
- (NSArray*) groups {
    //    NSManagedObjectModel *managedObjectModel = [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    //    NSFetchRequest *request = [managedObjectModel fetchRequestTemplateForName:@"fetchAllGroups"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    
    return mutableFetchResults;
}

- (void) addGroupWithName:(NSString*)name andTerminus:(NSString*)terminus {
    // Create and configure a new instance of the Favorite entity.
    Group* newGroupe = (Group*)[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
    newGroupe.name =  name;
    newGroupe.terminus = terminus;
}

- (void) removeGroup:(Group*)group {
    //Suppression du groupe
    [self.managedObjectContext deleteObject:group];
}

#pragma manage notifications
- (void) sendUpdateNotification {
    //lance la notification favoritesUpdated
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateGroups" object:self];
}

@end
