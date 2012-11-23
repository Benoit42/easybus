//
//  Route.h
//  EasyBus
//
//  Created by Benoit on 22/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Route : NSObject

@property(nonatomic) NSString* _id;
@property(nonatomic) NSString* _shortName;
@property(nonatomic) NSString* _longName;
@property(nonatomic) NSString* _fromName;
@property(nonatomic) NSString* _toName;

- (id)initWithId:(NSString*)id_ shortName:(NSString*)shortName_ longName:(NSString*)longName_;

@end
