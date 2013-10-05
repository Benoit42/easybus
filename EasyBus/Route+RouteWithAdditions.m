//
//  Route+Direction.m
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "Route+RouteWithAdditions.h"

@implementation Route (RouteWithAdditions)

- (NSString*)terminusForDirection:(NSString*)direction {
    if ([direction isEqualToString:@"0"]) {
        return self.fromName;
    }
    else {
        return self.toName;
    }
}

- (void)addStop:(Stop*)stop forDirection:(NSString*)direction andSequence:(NSUInteger)sequence {
    NSMutableOrderedSet* tempSet;
    if ([direction isEqual: @"0"]) {
        //[route insertObject:stop inStopsDirectionZeroAtIndex:0];
        tempSet = [self mutableOrderedSetValueForKey:@"stopsDirectionZero"];
    }
    else {
        //[route insertObject:stop inStopsDirectionOneAtIndex:0];
        tempSet = [self mutableOrderedSetValueForKey:@"stopsDirectionOne"];
    }
    if (![tempSet containsObject:stop]) {
        if (sequence < [tempSet count]) {
            [tempSet insertObject:stop atIndex:sequence];
        }
        else {
            [tempSet insertObject:stop atIndex:[tempSet count]];
        }
    }
}
@end
