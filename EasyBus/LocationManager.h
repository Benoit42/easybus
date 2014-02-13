//
//  LocationManager.h
//  EasyBus
//
//  Created by Benoit on 14/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

FOUNDATION_EXPORT NSString* const locationStartedNotification;
FOUNDATION_EXPORT NSString* const locationCanceledNotification;
FOUNDATION_EXPORT NSString* const locationFoundNotification;

@property(nonatomic) CLLocationManager* locationManager;
@property(nonatomic) CLLocation* currentLocation;

- (void) startUpdatingLocation;
- (void) stopUpdatingLocation;

@end
