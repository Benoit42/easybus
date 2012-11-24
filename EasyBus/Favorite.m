//
//  Case.m
//  CdeLineTool
//
//  Created by eu on 02/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Favorite.h"

@implementation Favorite

@synthesize ligne, libLigne, arret, libArret, direction, libDirection, pictoPath;

- (id)initWithName:(NSString*)ligne_ libLigne:(NSString*)libLigne_ arret:(NSString*)arret_ libArret:(NSString*)libArret_ direction:(NSString*)direction_ libDirection:(NSString*)libDirection_ {
    self = [super init];
    if (self) {
        self.ligne = ligne_;
        self.libLigne = libLigne_;
        self.arret = arret_;
        self.libArret = libArret_;
        self.direction = direction_;
        self.libDirection = libDirection_;
        self.pictoPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Pictogrammes_100-%i", [ligne_ intValue]] ofType:@"png"];
    }
    return self;
}

- (NSString*)key {
    return [Favorite key:self.ligne arret:self.arret  direction:self.direction ];
}

+ (NSString *) key:(NSString *)ligne_ arret:(NSString*)arret_ direction:(NSString*)direction_ {
    return [[NSString alloc] initWithFormat:@"%@-%@-%@", ligne_, arret_, direction_ ];
}

#pragma sauvegarde
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:ligne forKey:@"ligne"];
    [coder encodeObject:libLigne forKey:@"libLigne"];
    [coder encodeObject:arret forKey:@"arret"];
    [coder encodeObject:libArret forKey:@"libArret"];
    [coder encodeObject:direction forKey:@"direction"];
    [coder encodeObject:libDirection forKey:@"libDirection"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        ligne = [coder decodeObjectForKey:@"ligne"];
        libLigne = [coder decodeObjectForKey:@"libLigne"];
        arret = [coder decodeObjectForKey:@"arret"];
        libArret = [coder decodeObjectForKey:@"libArret"];
        direction = [coder decodeObjectForKey:@"direction"];
        libDirection = [coder decodeObjectForKey:@"libDirection"];
    }
    return self;
}

@end
