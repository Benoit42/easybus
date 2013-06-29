//
//  Stop.h
//  EasyBus
//
//  Created by Benoit on 26/06/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Route;

@interface Stop : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *routesDirectionsZero;
@property (nonatomic, retain) NSSet *routesDirectionOne;
@end

@interface Stop (CoreDataGeneratedAccessors)

- (void)addRoutesDirectionsZeroObject:(Route *)value;
- (void)removeRoutesDirectionsZeroObject:(Route *)value;
- (void)addRoutesDirectionsZero:(NSSet *)values;
- (void)removeRoutesDirectionsZero:(NSSet *)values;

- (void)addRoutesDirectionOneObject:(Route *)value;
- (void)removeRoutesDirectionOneObject:(Route *)value;
- (void)addRoutesDirectionOne:(NSSet *)values;
- (void)removeRoutesDirectionOne:(NSSet *)values;

@end
