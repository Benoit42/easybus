//
//  GtfsPublishDataTmp.h
//  EasyBus
//
//  Created by Benoit on 17/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GtfsPublishDataTmp : NSObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * publishDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSURL * url;
@property (nonatomic, retain) NSString * version;

@end
