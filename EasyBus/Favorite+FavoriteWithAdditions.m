//
//  Favorite+FavoriteWithAdditions.m
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "Favorite+FavoriteWithAdditions.h"
#import "Route+RouteWithAdditions.h"

@implementation Favorite (FavoriteWithAdditions)

- (NSString*)terminus {
    return [self.route terminusForDirection:self.direction];
}

@end
