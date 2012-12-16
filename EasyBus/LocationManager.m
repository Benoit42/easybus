//
//  LocationManager.m
//  EasyBus
//
//  Created by Benoit on 14/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

@synthesize locationManager, currentLocation;

#pragma singleton & init
//instancie le singleton
+ (LocationManager *)singleton
{
    static LocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LocationManager alloc] init];
    });
    return sharedInstance;
}

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

//Démarrage de la localisation
- (void) startUpdatingLocation {
    [locationManager startUpdatingLocation];
}

// Démarrage de la localisation
#pragma mark - Location Manager delegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0 && location.horizontalAccuracy < 100) {
        // If the event is recent and accurate, do something with it.
        currentLocation = location;

        //lance la notification d'erreur
        [[NSNotificationCenter defaultCenter] postNotificationName:@"locationFound" object:self];

        // Then stop location manager
        [locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //Log
    NSLog(@"Location failed! Error - %@ %@", [error description], [error debugDescription]);

    // inform the user
    UIAlertView *didFailWithErrorMessage = [[UIAlertView alloc] initWithTitle:@"Localisation" message:@"Erreur de localisation"  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [didFailWithErrorMessage show];    
}

@end
