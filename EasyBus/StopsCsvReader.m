//
//  RoutesStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "StopsCsvReader.h"
#import "CSVParser.h"

@implementation StopsCsvReader

@synthesize _stops;

- (id)init {
    if ( self = [super init] ) {
        _stops = [NSMutableDictionary new];
        
        NSError* error = nil;
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"stops" withExtension:@"txt"];
        
        NSString *csvString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        
        CSVParser* parser =
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
    Stop* stop = [[Stop alloc] initWithId:[aRecord objectForKey:@"stop_id"]
                                    code:[aRecord objectForKey:@"stop_code"]
                                    name:[aRecord objectForKey:@"stop_name"]
                                    desc:[aRecord objectForKey:@"stop_desc"]
                                     lat:[aRecord objectForKey:@"stop_lat"]
                                     lon:[aRecord objectForKey:@"stop_lon"]
                                     zoneId:[aRecord objectForKey:@"zone_id"]
                                     url:[aRecord objectForKey:@"stop_url"]
                                     locationType:[aRecord objectForKey:@"location_type"]
                                     parentStation:[aRecord objectForKey:@"parent_station"]
                                     timezone:[aRecord objectForKey:@"stop_timezone"]
                      whealchairBoardoing:[aRecord objectForKey:@"wheelchair_boarding"]];
 
    [_stops setObject:stop forKey:stop._id];
}


@end
