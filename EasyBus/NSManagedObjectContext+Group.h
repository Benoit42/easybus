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

FOUNDATION_EXPORT NSString* const updateGroups;

- (NSArray*) groups;
- (void) addGroupWithName:(NSString*)name andTerminus:(NSString*)terminus;
- (void) removeGroup:(Group*)group;

@end
