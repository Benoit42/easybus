//
//  LineReader.m
//  EasyBus
//
//  Created by Benoit on 18/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "RoutesCsvReader.h"
#import "CSVParser.h"

@implementation RoutesCsvReader

@synthesize _routes;

- (id)init {
    if ( self = [super init] ) {
        _routes = [NSMutableArray new];
        
        //Chargement des routes standards
        NSError* error = nil;
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"routes" withExtension:@"txt"];
        NSString *csvString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    	
        CSVParser* parser =
        [[CSVParser alloc]
         initWithString:csvString
         separator:@","
         hasHeader:YES
         fieldNames:nil];
        [parser parseRowsForReceiver:self selector:@selector(receiveRecord:)];

        //Chargement des routes suplémentaires
        url = [[NSBundle mainBundle] URLForResource:@"routes_extras" withExtension:@"txt"];
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
    Route *route = [[Route alloc] initWithId:[aRecord objectForKey:@"route_id"] shortName:[aRecord objectForKey:@"route_short_name"] longName:[aRecord objectForKey:@"route_long_name"]];
    [_routes addObject:route];
}

@end
