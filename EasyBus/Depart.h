//
//  Case.h
//  CdeLineTool
//
//  Created by eu on 02/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stop.h"
#import "Route+Additions.h"

@interface Depart : NSObject

@property(nonatomic) Route* route;
@property(nonatomic) Stop* stop;
@property(nonatomic) NSString* _direction;
@property(nonatomic) NSDate* _heure;
@property(nonatomic) NSTimeInterval _delai;
@property(nonatomic) BOOL isRealTime;

- (id)initWithRoute:(Route*)route stop:(Stop*)stop direction:(NSString*)direction delai:(NSTimeInterval)delai heure:(NSDate*)heure isRealTime:(BOOL)isRealTime;

@end
