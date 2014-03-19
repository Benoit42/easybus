//
//  FavoriteGroup.m
//  EasyBus
//
//  Created by Benoît on 07/03/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import "FavoriteGroup.h"
#import "Trip.h"


@implementation FavoriteGroup

@dynamic trips;

- (void)removeTripsObject:(Trip *)removedTrip {
    NSSet *changedObjects = [NSSet setWithObject:removedTrip];
    [self willChangeValueForKey:@"trips" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    NSMutableSet* trips = [self primitiveValueForKey:@"trips"];
    [trips removeObject:removedTrip];

    //Delete previous group if no more trips
    if (trips.count == 0) {
        [self.managedObjectContext deleteObject:self];
    }

    [self didChangeValueForKey:@"trips" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
}

- (void)removeTrips:(NSSet *)removedTrips {
    [self willChangeValueForKey:@"trips" withSetMutation:NSKeyValueMinusSetMutation usingObjects:removedTrips];
    NSMutableSet* trips = [self primitiveValueForKey:@"trips"];
    [trips minusSet:removedTrips];

    //Delete previous group if no more trips
    if (trips.count == 0) {
        [self.managedObjectContext deleteObject:self];
    }

    [self didChangeValueForKey:@"trips" withSetMutation:NSKeyValueMinusSetMutation usingObjects:removedTrips];
}
@end
