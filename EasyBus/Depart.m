//
//  Case.m
//  CdeLineTool
//
//  Created by eu on 02/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Depart.h"

@interface Depart()

@property(nonatomic) UIImage* _picto;

@end

@implementation Depart

- (id)initWithRoute:(Route*)route_ stop:(Stop*)stop_ direction:(NSString*)direction delai:(NSTimeInterval)delai heure:(NSDate*)heure isRealTime:(BOOL)isRealTime_ {
    self = [super init];
    if (self) {
        self.route = route_;
        self.stop = stop_;
        self._direction = direction;
        self._delai = delai;
        self._heure = heure;
        self.isRealTime = isRealTime_;
    }
    return self;
}

@end
