//
//  Route+Direction.h
//  EasyBus
//
//  Created by Benoit on 31/08/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "Route.h"

@interface Route (RouteWithAdditions)

- (NSString*)terminusForDirection:(NSString*)direction;
- (void)addStop:(Stop*)stop forDirection:(NSString*)direction andSequence:(NSUInteger)sequence;
@end
