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

//Déclaration des notifications
NSString* const locationStartedNotification = @"locationStartedNotification";
NSString* const locationCanceledNotification = @"locationCanceledNotification";
NSString* const locationFoundNotification = @"locationFoundNotification";

#pragma singleton & init
//constructeur
-(id)init {
    if ( self = [super init] ) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter = 500;
        [self.locationManager startUpdatingLocation];
    }
    return self;
}

//Démarrage/arrêt de la localisation
- (void) startUpdatingLocation {
    //Log
    NSLog(@"Geo-location started");

    //Démarrage de la géolocalisation
    [self.locationManager startUpdatingLocation];

    //Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:locationStartedNotification object:self];
}

- (void) stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:locationCanceledNotification object:self];
}

// Démarrage de la localisation
#pragma mark - Location Manager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //Log
    NSLog(@"Geo-location succeeded");
    
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
        self.currentLocation = location;

        //lance la notification de localisation
        [[NSNotificationCenter defaultCenter] postNotificationName:locationFoundNotification object:self];

        // Then stop location manager
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //Log
    NSLog(@"Geo-location - Error : %@ %@", [error description], [error debugDescription]);
}

@end
