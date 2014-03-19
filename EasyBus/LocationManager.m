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
NSString* const locationFailedNotification = @"locationFailedNotification";
NSString* const locationFoundNotification = @"locationFoundNotification";

#pragma singleton & init
//constructeur
-(id)init {
    if ( self = [super init] ) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        self.locationManager.distanceFilter = 10;
    }
    return self;
}

- (void) dealloc {
    //Arrêt de al géolocalisaton
    [self.locationManager stopUpdatingLocation];
}

//Démarrage/arrêt de la localisation
- (void) updateLocation {
    //Démarrage de la géolocalisation uniquement si trop vielle ou insuffisament précise
    CLLocation* location = self.locationManager.location;
    CLLocationAccuracy horizontalAccuracy = location.horizontalAccuracy;
    NSTimeInterval age = [location.timestamp timeIntervalSinceNow];
    if (!location || (horizontalAccuracy > 100 || age < -60)) {
        //Log
        NSLog(@"Geo-location started");

        //Démarrage
        [self.locationManager startUpdatingLocation];
        
        //Notification
        [[NSNotificationCenter defaultCenter] postNotificationName:locationStartedNotification object:self];

        //Arrêt de la géolocalisation après 30s
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //Arrêt
            [self.locationManager stopUpdatingLocation];

            //Log
            NSLog(@"Geo-location stopped");
        });
    }
}

- (CLLocation*)location {
    return self.locationManager.location;
}

// Démarrage de la localisation
#pragma mark - Location Manager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //Log
    NSLog(@"Geo-location updating");
    
    // test that the horizontal accuracy does not indicate an invalid measurement
    if (self.locationManager.location.horizontalAccuracy > 0) {
        NSLog(@"Geo-location succeeded : accuracy = %f", self.locationManager.location.horizontalAccuracy);
        //lance la notification de localisation
        [[NSNotificationCenter defaultCenter] postNotificationName:locationFoundNotification object:self];
    }

    //Stop location if accuracy is sufficient
    if (self.locationManager.location.horizontalAccuracy <= 10) {
        //Arrêt
        [self.locationManager stopUpdatingLocation];
        
        //Log
        NSLog(@"Geo-location stopped");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //Log
    NSLog(@"Geo-location - Error : %@ %@", [error description], [error debugDescription]);

    
    //Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:locationFailedNotification object:self];
}

@end
