//
//  GtfsPublishData.h
//  EasyBus
//
//  Created by Benoit on 25/10/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GtfsPublishData : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * publishDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * version;

@end
