//
//  LocationManagerTest.m
//  EasyBus
//
//  Created by Benoit on 24/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManagerTest : XCTestCase

@end

@implementation LocationManagerTest : XCTestCase

//Test de l'ajout
- (void)testDistanceComputation
{
    //Instaciation des coordonnées
    CLLocation* maison = [[CLLocation alloc] initWithLatitude:+48.138149 longitude:-1.523640];
    CLLocation* bureau = [[CLLocation alloc] initWithLatitude:+48.130748 longitude:-1.624517];
    CLLocation* timoniere = [[CLLocation alloc] initWithLatitude:+48.137035 longitude:-1.526311];
    CLLocation* closcourtel = [[CLLocation alloc] initWithLatitude:+48.127336 longitude:-1.627581];

    
    CLLocationDistance maisonTimoniere = [maison distanceFromLocation:timoniere];
    CLLocationDistance maisonCloscourtel = [maison distanceFromLocation:closcourtel];
    CLLocationDistance bureauTimoniere = [bureau distanceFromLocation:timoniere];
    CLLocationDistance bureauCloscourtel = [bureau distanceFromLocation:closcourtel];
    
    //Vérification
    XCTAssertTrue(maisonTimoniere < maisonCloscourtel, @"Error in distance computing");
    XCTAssertTrue(bureauCloscourtel < bureauTimoniere, @"Error in distance computing");
}

@end
