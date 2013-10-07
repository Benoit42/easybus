//
//  Stop.h
//  EasyBus
//
//  Created by Benoit on 06/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StopSequence;

@interface Stop : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *stopSequence;
@end

@interface Stop (CoreDataGeneratedAccessors)

- (void)addStopSequenceObject:(StopSequence *)value;
- (void)removeStopSequenceObject:(StopSequence *)value;
- (void)addStopSequence:(NSSet *)values;
- (void)removeStopSequence:(NSSet *)values;

@end
