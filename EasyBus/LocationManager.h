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

@property(nonatomic) CLLocationManager* locationManager;
@property(nonatomic) CLLocation* currentLocation;

+ (LocationManager*) singleton;
- (void) startUpdatingLocation;

@end
