//
//  LocationManager.m
//  EasyBus
//
//  Created by Benoit on 14/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "LocationManager.h"

@implementation LocationManager
objection_register_singleton(LocationManager)

@synthesize locationManager, currentLocation;

#pragma singleton & init
//constructeur
-(id)init {
    if ( self = [super init] ) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.distanceFilter = 500;
        [locationManager startUpdatingLocation];
    }
    return self;
}

//Démarrage/arrêt de la localisation
- (void) startUpdatingLocation {
    [locationManager startUpdatingLocation];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationStarted" object:self];
}

- (void) stopUpdatingLocation {
    [locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationCanceled" object:self];
}

// Démarrage de la localisation
#pragma mark - Location Manager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];

    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[location.timestamp timeIntervalSinceNow];
    if (locationAge > 15.0) return;

    // test that the horizontal accuracy does not indicate an invalid measurement
    if (location.horizontalAccuracy < 0) return;

    if (location.horizontalAccuracy <= 300) {
        // If the event is recent and accurate, do something with it.
        currentLocation = location;

        //lance la notification de localisation
        [[NSNotificationCenter defaultCenter] postNotificationName:@"locationFound" object:self];

        // Then stop location manager
        [locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //Log
    NSLog(@"Location failed! Error - %@ %@", [error description], [error debugDescription]);
}

@end
