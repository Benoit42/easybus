//
//  Trip.m
//  EasyBus
//
//  Created by Benoît on 07/03/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import "Trip.h"
#import "FavoriteGroup.h"
#import "ProximityGroup.h"
#import "Route.h"
#import "Stop.h"


@implementation Trip

@dynamic direction;
@dynamic favoriteGroup;
@dynamic route;
@dynamic stop;
@dynamic proximityGroup;

- (void)setFavoriteGroup:(FavoriteGroup *)favoriteGroup {
    FavoriteGroup* previousFavoriteGroup = self.favoriteGroup;
    if (favoriteGroup != previousFavoriteGroup) {
        //Set new favoriteGroup
        [self willChangeValueForKey:@"favoriteGroup"];
        [self setPrimitiveValue:favoriteGroup forKey:@"favoriteGroup"];
        [self didChangeValueForKey:@"favoriteGroup"];
        
        //Delete previous group if no more trips
        if (previousFavoriteGroup && previousFavoriteGroup.trips.count == 0) {
            [self.managedObjectContext deleteObject:previousFavoriteGroup];
        }
    }
}

@end
