//
//  RouteStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CHCSVParser/CHCSVParser.h>
#import "RoutesStopsCsvReader.h"
#import "StaticDataManager.h"

@interface RoutesStopsCsvReader() <CHCSVParserDelegate>

@property (nonatomic, strong) NSMutableArray* row;

@end

@implementation RoutesStopsCsvReader
objection_register_singleton(RoutesStopsCsvReader)

- (void)loadData:(NSURL*)url {
    //Chargement des horaires
    NSLog(@"Chargement des associations routes/stops");
    
    //Allocation du dictionnaire
    self.routesStops = [[NSMutableArray alloc] initWithCapacity:5000U];
    
    //Lecture du fichier
    //Question : pourquoi est-il plus rapide de lire préalablement le fichier ?
    NSString *csvString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    //parsing du fichier
    self.row = [[NSMutableArray alloc] init];
    CHCSVParser * p = [[CHCSVParser alloc] initWithCSVString:csvString];
    p.sanitizesFields = YES;
    [p setDelegate:self];
    [p parse];
}

#pragma mark CHCSVParserDelegate methods
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    [self.row removeAllObjects];
}

- (void) parser:(CHCSVParser *)parser didEndLine:(NSUInteger)lineNumber {
    if (self.row.count == 4) {
        // Create and configure a new instance of the StopTime entity.
        RouteStop* routeStop = [[RouteStop alloc] init];
        routeStop.routeId = self.row[0];
        routeStop.stopId = self.row[1];
        routeStop.directionId = self.row[2];
        routeStop.stopSequence = [NSNumber numberWithInteger:[self.row[3] integerValue]];
        
        [self.routesStops addObject:routeStop];
    }
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    [self.row addObject:field];
}

- (void) parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"RoutesStopsCsvReader parser failed with error: %@ %@", [error localizedDescription], [error userInfo]);
}


- (void)cleanUp {
    self.routesStops = nil;
}


@end
