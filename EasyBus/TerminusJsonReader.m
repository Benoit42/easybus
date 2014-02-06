//
//  RouteStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "TerminusJsonReader.h"

@interface TerminusJsonReader()

@property (nonatomic, strong) NSMutableArray* row;

@end

@implementation TerminusJsonReader
objection_register_singleton(TerminusJsonReader)

- (void)loadData:(NSURL*)url {
    //Chargement des horaires
    NSLog(@"Chargement des terminus");
    
    //Initialisation du progress
    self.progress = [NSProgress progressWithTotalUnitCount:100]; //approx
    
    //Chargement du dictionnaire
    NSData* json = [NSData dataWithContentsOfURL:url];
    NSError* error;
    self.terminus = [NSJSONSerialization JSONObjectWithData:json options:nil error:&error];
    if (error) {
        NSLog(@"%@", [error description]);
    }
    
    //Progress
    [self.progress setCompletedUnitCount:100];
}

- (void)cleanUp {
    self.terminus = nil;
}

@end
