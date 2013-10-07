//
//  Route+Direction.m
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "Route+RouteWithAdditions.h"
#import "Stop.h"
#import "StopSequence.h"

@implementation Route (RouteWithAdditions)

- (NSString*)terminusForDirection:(NSString*)direction {
    if ([direction isEqualToString:@"0"]) {
        return self.fromName;
    }
    else {
        return self.toName;
    }
}

//- (void)addStop:(StopSequence*)stopSequence forDirection:(NSString*)direction {
//    if ([direction isEqual: @"0"]) {
//        [self insertStopsDirectionZero:@[stopSequence] atIndexes:[NSIndexSet indexSetWithIndex:sequence]];
//    }
//    else {
//        [self insertStopsDirectionOne:@[stopSequence] atIndexes:[NSIndexSet indexSetWithIndex:sequence]];
//    }
//}

- (void)addStop:(StopSequence*)stopSequence forDirection:(NSString*)direction {
    NSMutableOrderedSet* tempSet;
    if ([direction isEqualToString: @"0"]) {
        //[route insertObject:stop inStopsDirectionZeroAtIndex:0];
        tempSet = [self mutableOrderedSetValueForKey:@"stopsSequenceDirectionZero"];
    }
    else {
        //[route insertObject:stop inStopsDirectionOneAtIndex:0];
        tempSet = [self mutableOrderedSetValueForKey:@"stopsSequenceDirectionOne"];
    }

    //Ajout de l'arrêt
    [tempSet addObject:stopSequence];
    
    //Tri
    [tempSet sortUsingComparator:^NSComparisonResult(StopSequence* stop1, StopSequence* stop2) {
        return [stop1.sequence compare:stop2.sequence];
    }];
}

@end
