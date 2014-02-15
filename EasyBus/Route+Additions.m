//
//  Route+Direction.m
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "Route+Additions.h"
#import "Stop.h"

@implementation Route (Additions)

- (NSString*)terminusForDirection:(NSString*)direction {
    if ([direction isEqualToString:@"0"]) {
        return self.fromName;
    }
    else {
        return self.toName;
    }
}

- (void)addStop:(Stop*)stop forDirection:(NSString*)direction {
    if ([direction isEqualToString: @"0"]) {
        [self addStopsDirectionZeroObject:stop];
    }
    else {
        [self addStopsDirectionOneObject:stop];
    }
}

- (NSURL*) pictoUrl {
    NSString* url = [NSString stringWithFormat:@"http://data.keolis-rennes.com/fileadmin/documents/Picto_lignes/Pictos_lignes_100x100/L%@.png", self.shortName];
    NSString* encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSURL URLWithString:encodedUrl];
}

@end
