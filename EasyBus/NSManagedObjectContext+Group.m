//
//  NSManagedObjectContext+Group.m
//  EasyBus
//
//  Created by Benoît on 12/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import "NSManagedObjectContext+Group.h"
#import "NSManagedObjectContext+Trip.h"
#import "NSManagedObjectContext+Network.h"
#import "Trip+Additions.h"

@implementation NSManagedObjectContext (Group)

#pragma mark - Model
- (NSManagedObjectModel*)managedObjectModel {
    return self.persistentStoreCoordinator.managedObjectModel;
}

#pragma mark - Manage groupes
- (NSArray*) allGroups {
    NSMutableArray* allGroups = [[NSMutableArray alloc] init];
    ProximityGroup* proximityGroup = [self proximityGroup];
    if (proximityGroup) {
        [allGroups addObject:proximityGroup];
    }
    [allGroups addObjectsFromArray:[self favoriteGroups]];
    return allGroups;
}

- (Group*) addFavoriteGroupWithName:(NSString*)name {
    // Create and configure a new instance of the Group entity.
    Group* group = (Group*)[NSEntityDescription insertNewObjectForEntityForName:@"FavoriteGroup" inManagedObjectContext:self];
    group.name =  name;
    
    //Retour
    return group;
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

- (ProximityGroup*) proximityGroup {
    NSFetchRequest *request = [self.managedObjectModel fetchRequestTemplateForName:@"fetchProximityGroup"];
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

- (ProximityGroup*) updateProximityGroupForLocation:(CLLocation*)location {
    //Get existing group
    ProximityGroup* proximityGroup = [self proximityGroup];

    if (!proximityGroup) {
        //Not existing, create it
        proximityGroup = (ProximityGroup*)[NSEntityDescription insertNewObjectForEntityForName:@"ProximityGroup" inManagedObjectContext:self];
        proximityGroup.name =  @"à proximité";
    }
    else {
        //Already existing, cleaning it up
        NSSet* proximityTrips = [proximityGroup trips];
        [proximityGroup removeTrips:proximityTrips];
        [proximityTrips enumerateObjectsUsingBlock:^(Trip* trip, BOOL *stop) {
            if (!trip.favoriteGroup) {
                //Le trajet n'est rattaché à aucun groupe de favoris, on le supprime
                [self deleteObject:trip];
            }
        }];
    }
    
    //Compute trips
    if (location) {
        //Calcul des arrêts proches
        NSArray* stops = [self nearestStopsHavingSameNameFrom:location];
        
        //Set trips in group
        proximityGroup.name = (stops.count > 0)?((Stop*)stops[0]).name:@"à proximité";
        [stops enumerateObjectsUsingBlock:^(Stop* selectedStop, NSUInteger idx, BOOL *stop) {
            [selectedStop.routesDirectionZero enumerateObjectsUsingBlock:^(Route* route, BOOL *stop) {
                if ([route.stopsDirectionZero lastObject] != selectedStop) {
                    //On n'ajoute pas le dernier stop d'une ligne
                    Trip* trip = [self addTrip:route stop:selectedStop direction:@"0"];
                    [proximityGroup addTripsObject:trip];
                }
            }];
            [selectedStop.routesDirectionOne enumerateObjectsUsingBlock:^(Route* route, BOOL *stop) {
                if ([route.stopsDirectionOne lastObject] != selectedStop) {
                    //On n'ajoute pas le dernier stop d'une ligne
                    Trip* trip = [self addTrip:route stop:selectedStop direction:@"1"];
                    [proximityGroup addTripsObject:trip];
                }
            }];
        }];
    }
    else {
        //Pas de géoloc obtenue
        proximityGroup.name = @"position inconnue";
    }
    
    //Retour
    return proximityGroup;
}

@end
