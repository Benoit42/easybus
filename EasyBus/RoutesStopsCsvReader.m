//
//  RouteStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "RoutesStopsCsvReader.h"
#import "CSVParser.h"
#import "RouteStop.h"

@implementation RoutesStopsCsvReader

@synthesize _routeStops;

- (id)init {
    if ( self = [super init] ) {
        _routeStops = [NSMutableDictionary new];
        
        //Chargement des arrêts standards
        NSError* error = nil;
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"routes_stops" withExtension:@"txt"];
        NSString *csvString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        
        CSVParser* parser =
        [[CSVParser alloc]
         initWithString:csvString
         separator:@","
         hasHeader:YES
         fieldNames:nil];
        [parser parseRowsForReceiver:self selector:@selector(receiveRecord:)];

        //Chargement des arrêts supplémentaires
        url = [[NSBundle mainBundle] URLForResource:@"routes_stops_extras" withExtension:@"txt"];
        csvString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        
        parser =
        [[CSVParser alloc]
         initWithString:csvString
         separator:@","
         hasHeader:YES
         fieldNames:nil];
        [parser parseRowsForReceiver:self selector:@selector(receiveRecord:)];
}
    return self;
}

- (void)receiveRecord:(NSDictionary *)aRecord
{
    RouteStop* routeStop = [[RouteStop alloc] initWithRouteId:[aRecord objectForKey:@"route_id"] stopId:[aRecord objectForKey:@"stop_id"] directionId:[aRecord objectForKey:@"direction_id"] sequence:[aRecord objectForKey:@"stop_sequence"]];
    
    NSMutableArray* stops = [_routeStops objectForKey:[NSString stringWithFormat:@"%@-%@", routeStop._routeId, routeStop._directionId]];
    if (stops == nil) {
        stops = [NSMutableArray new];
        [_routeStops setObject:stops forKey:[NSString stringWithFormat:@"%@-%@", routeStop._routeId, routeStop._directionId]];
    }
    [stops addObject:routeStop];
}


@end
