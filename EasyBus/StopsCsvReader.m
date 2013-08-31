//
//  RoutesStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "StopsCsvReader.h"
#import "CSVParser.h"

@interface StopsCsvReader()

@property (nonatomic, retain, readonly) NSManagedObjectContext *_managedObjectContext;

- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext;

@end

@implementation StopsCsvReader

@synthesize _managedObjectContext;

- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext {
    if ( self = [super init] ) {
        //initialisation des membres
        _managedObjectContext = managedObjectContext;
    }
    return self;
}

- (void)loadData {
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
    
    //Sauvegarde des données
    if (![_managedObjectContext save:&error]) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }

}

- (void)receiveRecord:(NSDictionary *)aRecord {
    // Create and configure a new instance of the Stop entity.
    Stop* stop = (Stop*)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" inManagedObjectContext:_managedObjectContext];
    stop.id = [aRecord objectForKey:@"stop_id"];
    stop.code = [aRecord objectForKey:@"stop_code"];
    stop.name = [aRecord objectForKey:@"stop_name"];
    stop.desc = [aRecord objectForKey:@"stop_desc"];
    stop.latitude = [aRecord objectForKey:@"stop_lat"];
    stop.longitude = [aRecord objectForKey:@"stop_lon"];
}

@end
