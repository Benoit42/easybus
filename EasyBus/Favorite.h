//
//  Case.h
//  CdeLineTool
//
//  Created by eu on 02/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Favorite : NSObject <NSCoding>

@property(nonatomic) NSString* ligne;
@property(nonatomic) NSString* libLigne;
@property(nonatomic) NSString* arret;
@property(nonatomic) NSString* libArret;
@property(nonatomic) NSString* direction;
@property(nonatomic) NSString* libDirection;
@property(nonatomic) double lat;
@property(nonatomic) double lon;

- (id)initWithName:(NSString*)ligne_ libLigne:(NSString*)libLigne_ arret:(NSString*)arret_ libArret:(NSString*)libArret_ direction:(NSString*)direction_ libDirection:(NSString*)libDirection_ lat:(double)lat_ lon:(double)lon_;

- (UIImage*)picto;

@end
