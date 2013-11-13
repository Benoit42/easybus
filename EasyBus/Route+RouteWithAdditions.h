//
//  Route+Direction.h
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "Route.h"
#import "Stop.h"

@interface Route (RouteWithAdditions)

- (NSString*)terminusForDirection:(NSString*)direction;
- (void)addStop:(Stop*)stop forSequence:(NSNumber*)sequence forDirection:(NSString*)direction;
- (NSURL*) pictoUrl;

@end
