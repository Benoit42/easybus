//
//  NSManagedObjectContext+Trip.h
//  EasyBus
//
//  Created by Benoît on 09/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Trip.h"
#import "Route.h"
#import "Stop.h"
#import "Group.h"

@interface NSManagedObjectContext (Trip)

- (NSArray*) trips;
- (Trip*) addTrip:(Route*)route stop:(Stop*)stop direction:(NSString*)direction;
- (void) moveTrip:(Trip*)trip fromGroup:(Group*)sourceGroup toGroup:(Group*)destinationGroup atIndex:(NSUInteger)index;

@end
