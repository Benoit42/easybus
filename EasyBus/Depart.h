//
//  Case.h
//  CdeLineTool
//
//  Created by eu on 02/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Depart : NSObject

@property(nonatomic) NSString* _ligne;
@property(nonatomic) NSString* _arret;
@property(nonatomic) NSString* _direction;
@property(nonatomic) NSString* _headsign;
@property(nonatomic) NSTimeInterval _delai;

- (id)initWithName:(NSString*)ligne_ arret:(NSString*)arret_ direction:(NSString*)direction_ headsign:(NSString*)headsign_ delai:(NSTimeInterval)delai_;

@end
