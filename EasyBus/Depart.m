//
//  Case.m
//  CdeLineTool
//
//  Created by eu on 02/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Depart.h"

@implementation Depart

@synthesize _ligne, _arret, _direction, _headsign, _delai;

- (id)initWithName:(NSString*)ligne_ arret:(NSString*)arret_ direction:(NSString*)direction_ headsign:(NSString*)headsign_ delai:(NSTimeInterval)delai_ {
    self = [super init];
    if (self) {
        self._ligne = ligne_;
        self._arret = arret_;
        self._direction = direction_;
        self._headsign = headsign_;
        self._delai = delai_;
    }
    return self;
}

@end
