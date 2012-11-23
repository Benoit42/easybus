//
//  Stop.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "Stop.h"

@implementation Stop

@synthesize _id, _code, _name, _desc, _lat, _lon, _zone_id, _url, _location_type, _parent_station, _timezone, _wheelchair_boarding;

- (id)initWithId:(NSString*)id_ code:(NSString*)code_ name:(NSString*)name_ desc:(NSString*)desc_ lat:(NSString*)lat_ lon:(NSString*)lon_ zoneId:(NSString*)zone_id_ url:(NSString*)url_ locationType:(NSString*)location_type_ parentStation:(NSString*)parent_station_ timezone:(NSString*)timezone_ whealchairBoardoing:(NSString*)wheelchair_boarding_  {
    _id = id_;
    _code = code_;
    _name = name_;
    _desc = desc_;
    _lat = lat_;
    _lon = lon_;
    _zone_id = zone_id_;
    _url = url_;
    _location_type = location_type_;
    _parent_station = parent_station_;
    _timezone = timezone_;
    _wheelchair_boarding = wheelchair_boarding_;

    return self;
}

@end
