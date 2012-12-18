//
//  Case.m
//  CdeLineTool
//
//  Created by eu on 02/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Favorite.h"

@interface Favorite()

@property(nonatomic) UIImage* _picto;

@end

@implementation Favorite

@synthesize ligne, libLigne, arret, libArret, direction, libDirection, _picto, lat, lon;

- (id)initWithName:(NSString*)ligne_ libLigne:(NSString*)libLigne_ arret:(NSString*)arret_ libArret:(NSString*)libArret_ direction:(NSString*)direction_ libDirection:(NSString*)libDirection_ lat:(double)lat_ lon:(double)lon_ {
    self = [super init];
    if (self) {
        self.ligne = ligne_;
        self.libLigne = libLigne_;
        self.arret = arret_;
        self.libArret = libArret_;
        self.direction = direction_;
        self.libDirection = libDirection_;
        self.lat = lat_;
        self.lon = lon_;
    }
    return self;
}

- (UIImage*) picto {
    if (_picto == nil) {
        _picto = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Pictogrammes_100\\%i", [ligne intValue]] ofType:@"png"]];
    }
    return _picto;
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
    [coder encodeDouble:lat forKey:@"lat"];
    [coder encodeDouble:lon forKey:@"lon"];
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
        lat = [coder decodeDoubleForKey:@"lat"];
        lon = [coder decodeDoubleForKey:@"lon"];
    }
    return self;
}

@end
