//
//  FavoritesManager.h
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Group.h"

@interface GroupManager : NSObject

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (NSArray*) groups;
- (void) addGroupWithName:(NSString*)name andTerminus:(NSString*)terminus;
- (void) removeGroup:(Group*)group;

@end
