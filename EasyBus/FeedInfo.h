//
//  FeedInfo.h
//  EasyBus
//
//  Created by Benoît on 27/01/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FeedInfo : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * publishDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * version;

@end
