//
//  Route+Direction.m
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "Route+RouteWithAdditions.h"
#import "Stop.h"

@implementation Route (RouteWithAdditions)

- (NSString*)terminusForDirection:(NSString*)direction {
    if ([direction isEqualToString:@"0"]) {
        return self.fromName;
    }
    else {
        return self.toName;
    }
}

- (void)addStop:(Stop*)stop forSequence:(NSNumber*)sequence forDirection:(NSString*)direction {    NSMutableOrderedSet* tempSet;
    if ([direction isEqualToString: @"0"]) {
        //[route insertObject:stop inStopsDirectionZeroAtIndex:0];
        tempSet = [self mutableOrderedSetValueForKey:@"stopsDirectionZero"];
    }
    else {
        //[route insertObject:stop inStopsDirectionOneAtIndex:0];
        tempSet = [self mutableOrderedSetValueForKey:@"stopsDirectionOne"];
    }

    //Ajout de l'arrêt
    [tempSet addObject:stop];
}

- (NSURL*) pictoUrl {
    NSString* url = [NSString stringWithFormat:@"http://data.keolis-rennes.com/fileadmin/documents/Picto_lignes/Pictos_lignes_100x100/L%@.png", self.shortName];
    NSString* encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:encodedUrl];
}

@end
