//
//  NSManagedObjectContext+Favorite.h
//  EasyBus
//
//  Created by Benoît on 09/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Favorite.h"
#import "Route.h"
#import "Stop.h"
#import "Group.h"

@interface NSManagedObjectContext (Favorite)

- (NSArray*) favorites;
- (Favorite*) addFavorite:(Route*)route stop:(Stop*)stop direction:(NSString*)direction;
- (void) moveFavorite:(Favorite*)favorite fromGroup:(Group*)sourceGroup toGroup:(Group*)destinationGroup atIndex:(NSUInteger)index;

@end
