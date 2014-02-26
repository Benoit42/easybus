//
//  NSManagedObjectContext+Group.h
//  EasyBus
//
//  Created by Benoît on 12/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Group.h"

@interface NSManagedObjectContext (Group)

- (NSArray*) allGroups;
- (NSArray*) favoriteGroups;
- (Group*) nearStopGroup;
- (Group*) addGroupWithName:(NSString*)name isNearStopGroup:(BOOL)isNearStopGroup;
@end
