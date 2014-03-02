//
//  Stop.h
//  EasyBus
//
//  Created by Benoît on 28/02/2014.
//  Copyright (c) 2014 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Route, Trip;

@interface Stop : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) id location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *routesDirectionOne;
@property (nonatomic, retain) NSSet *routesDirectionZero;
@property (nonatomic, retain) NSSet *trips;
@end

@interface Stop (CoreDataGeneratedAccessors)

- (void)addRoutesDirectionOneObject:(Route *)value;
- (void)removeRoutesDirectionOneObject:(Route *)value;
- (void)addRoutesDirectionOne:(NSSet *)values;
- (void)removeRoutesDirectionOne:(NSSet *)values;

- (void)addRoutesDirectionZeroObject:(Route *)value;
- (void)removeRoutesDirectionZeroObject:(Route *)value;
- (void)addRoutesDirectionZero:(NSSet *)values;
- (void)removeRoutesDirectionZero:(NSSet *)values;

- (void)addTripsObject:(Trip *)value;
- (void)removeTripsObject:(Trip *)value;
- (void)addTrips:(NSSet *)values;
- (void)removeTrips:(NSSet *)values;

@end
