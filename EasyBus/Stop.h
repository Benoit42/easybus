//
//  Stop.h
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stop : NSObject

@property(nonatomic) NSString* _id;
@property(nonatomic) NSString* _code;
@property(nonatomic) NSString* _name;
@property(nonatomic) NSString* _desc;
@property(nonatomic) NSString* _lat;
@property(nonatomic) NSString* _lon;
@property(nonatomic) NSString* _zone_id;
@property(nonatomic) NSString* _url;
@property(nonatomic) NSString* _location_type;
@property(nonatomic) NSString* _parent_station;
@property(nonatomic) NSString* _timezone;
@property(nonatomic) NSString* _wheelchair_boarding;

- (id)initWithId:(NSString*)id_ code:(NSString*)code_ name:(NSString*)name_ desc:(NSString*)desc_ lat:(NSString*)lat_ lon:(NSString*)lon_ zoneId:(NSString*)zone_id_ url:(NSString*)url_ locationType:(NSString*)location_type_ parentStation:(NSString*)parent_station_ timezone:(NSString*)timezone_ whealchairBoardoing:(NSString*)wheelchair_boarding_;

@end
