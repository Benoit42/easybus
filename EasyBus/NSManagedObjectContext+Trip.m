//
//  NSManagedObjectContext+Trip.m
//  EasyBus
//
//  Created by Benoît on 09/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import "NSManagedObjectContext+Trip.h"
#import "Trip+Additions.h"

@implementation NSManagedObjectContext (Trip)

#pragma mark - Model
- (NSManagedObjectModel*)managedObjectModel {
    return self.persistentStoreCoordinator.managedObjectModel;
}

#pragma - Manage trips
- (NSArray*) trips {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"fetchAllTrips"];
    
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

- (Trip*) tripForRoute:(Route*)route stop:(Stop*)stop direction:(NSString*)direction {
//TODO: Possible de mettre un template
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Trip"];
    request.predicate = [NSPredicate predicateWithFormat:@"route.id = %@ AND stop.id = %@ AND direction = %@", route.id, stop.id, direction];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"route.id" ascending:YES]];
    
    NSError *error = nil;
    NSArray *fetchResults = [self executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if ([fetchResults count] > 0) {
        //Should be 0 or 1 item
        return [fetchResults objectAtIndex:0];
    }
    return nil;
}

- (Trip*) addTrip:(Route*)route stop:(Stop*)stop direction:(NSString*)direction {
    //Recherche du favori
    Trip* trip = [self tripForRoute:route stop:stop direction:direction];
    
    if (trip == nil) {
        // Create and configure a new instance of the Trip entity.
        trip = (Trip*)[NSEntityDescription insertNewObjectForEntityForName:@"Trip" inManagedObjectContext:self];
        trip.route =  route;
        trip.stop = stop;
        trip.direction = direction;
    }
    
    //Retour
    return trip;
}

@end
