//
//  Route.m
//  EasyBus
//
//  Created by Benoit on 22/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "Route.h"

@interface Route()

@property(nonatomic) UIImage* _picto;

@end

@implementation Route

@synthesize _id, _shortName, _longName, _fromName, _toName, _picto;

- (id)initWithId:(NSString*)id_ shortName:(NSString*)shortName_ longName:(NSString*)longName_ {
    _id = id_;
    _shortName = shortName_;
    _longName = longName_;
    
    //Calcul des libellés des départs et arrivée
    //Exemple : "Rennes (République) <> Acigné"
    //Split sur le <> et suppression de la partie entre parenthèses
    NSArray* subs = [_longName componentsSeparatedByString:@"<>"];
    _fromName = ([subs count] > 0) ? [subs objectAtIndex:0] : @"Départ inconnu";
    _toName = ([subs count] > 1) ? [subs objectAtIndex:1] : @"Arrivée inconnue";

    subs = [_fromName componentsSeparatedByString:@"("];
    _fromName = ([subs count] > 0) ? [subs objectAtIndex:0] : _fromName;
    _fromName = [_fromName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

    subs = [_toName componentsSeparatedByString:@"("];
    _toName = ([subs count] > 0) ? [subs objectAtIndex:0] : _toName;
    _toName = [_toName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

    return self;
}

- (UIImage*) picto {
    if (_picto == nil) {
        _picto = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Pictogrammes_100\\%@", _shortName] ofType:@"png"]];
    }
    return _picto;
}

@end
