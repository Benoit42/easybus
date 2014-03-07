//
//  NSManagedObjectContext+Group.h
//  EasyBus
//
//  Created by Benoît on 12/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "FavoriteGroup.h"
#import "ProximityGroup.h"

@interface NSManagedObjectContext (Group)

- (NSArray*) allGroups;
- (NSArray*) favoriteGroups;
- (FavoriteGroup*) addFavoriteGroupWithName:(NSString*)name;
- (ProximityGroup*) proximityGroup;
- (ProximityGroup*) updateProximityGroupForLocation:(CLLocation*)location;

@end
