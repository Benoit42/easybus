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

@end
