//
//  RoutesStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CoreData/CoreData.h>
#import "StopsCsvReader.h"
#import "CSVParser.h"

@implementation StopsCsvReader
objection_register_singleton(StopsCsvReader)

objection_requires(@"managedObjectContext")
@synthesize managedObjectContext;

- (void)loadData {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    //Log
    NSLog(@"Chargement des stops");
    
    //Chargement des stops
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

- (void)receiveRecord:(NSDictionary *)aRecord {
    // Create and configure a new instance of the Stop entity.
    Stop* stop = (Stop*)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:self.managedObjectContext];
    stop.id = [aRecord objectForKey:@"stop_id"];
    stop.code = [aRecord objectForKey:@"stop_code"];
    stop.name = [aRecord objectForKey:@"stop_name"];
    stop.desc = [aRecord objectForKey:@"stop_desc"];
    stop.latitude = [aRecord objectForKey:@"stop_lat"];
    stop.longitude = [aRecord objectForKey:@"stop_lon"];
}

- (void)cleanUp {
    //nothing
}

@end
