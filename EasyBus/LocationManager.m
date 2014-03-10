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
    }
    return self;
}

//Démarrage/arrêt de la localisation
- (void) startUpdatingLocation {
    //Log
    NSLog(@"Geo-location started");

    //Démarrage de la géolocalisation
    [self.locationManager startMonitoringSignificantLocationChanges];

    //Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:locationStartedNotification object:self];
}

- (void) stopUpdatingLocation {
    NSLog(@"Geo-location stopped");

    [self.locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:locationCanceledNotification object:self];
}

- (void) forceUpdatingLocation; {
    NSLog(@"Geo-location refreshed");
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

// Démarrage de la localisation
#pragma mark - Location Manager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //Log
    NSLog(@"Geo-location updated");
    
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];

    // test that the horizontal accuracy does not indicate an invalid measurement
    if (location.horizontalAccuracy > 0) {
        NSLog(@"Geo-location succeeded : accuracy = %f", location.horizontalAccuracy);

        // If the event is recent and accurate, do something with it.
        self.currentLocation = location;

        //lance la notification de localisation
        [[NSNotificationCenter defaultCenter] postNotificationName:locationFoundNotification object:self];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //Log
    NSLog(@"Geo-location - Error : %@ %@", [error description], [error debugDescription]);
}

@end
