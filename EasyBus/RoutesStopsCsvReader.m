//
//  RouteStopsCsvReader.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "RoutesStopsCsvReader.h"
#import "StaticDataManager.h"
#import "CSVParser.h"

@implementation RoutesStopsCsvReader
objection_register_singleton(RoutesStopsCsvReader)

objection_requires(@"managedObjectContext")
@synthesize managedObjectContext;

//constructeur
//-(id)init {
//    if ( self = [super init] ) {
//        //Préconditions
//        NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
//    }
//    
//    return self;
//}

- (void)loadData {
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

- (void)receiveRecord:(NSDictionary *)aRecord
{
    Route* route = [self routeForId:[aRecord objectForKey:@"route_id"]];
    Stop* stop = [self stopForId:[aRecord objectForKey:@"stop_id"]];
    int sequence = [[aRecord objectForKey:@"stop_sequence"] intValue] - 1;
    
    NSMutableOrderedSet* tempSet;
    if ([[aRecord objectForKey:@"direction_id"] isEqual: @"0"]) {
        //[route insertObject:stop inStopsDirectionZeroAtIndex:0];
        tempSet = [route mutableOrderedSetValueForKey:@"stopsDirectionZero"];
    }
    else {
        //[route insertObject:stop inStopsDirectionOneAtIndex:0];
        tempSet = [route mutableOrderedSetValueForKey:@"stopsDirectionOne"];
    }
    if (sequence < [tempSet count]) {
        [tempSet insertObject:stop atIndex:sequence];
    }
    else {
        [tempSet insertObject:stop atIndex:[tempSet count]];
    }
}

- (Route*) routeForId:(NSString*)routeId {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    NSManagedObjectModel *managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *request = [managedObjectModel fetchRequestFromTemplateWithName:@"fetchRouteWithId"
                                                              substitutionVariables:@{@"id" : routeId}];
    NSError *error = nil;
    NSArray* routes = [self.managedObjectContext executeFetchRequest:request error:&error];
    return ([routes count] == 0) ? nil : [routes objectAtIndex:0];
}

- (Stop*) stopForId:(NSString*)stopId {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    NSManagedObjectModel *managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *request = [managedObjectModel fetchRequestFromTemplateWithName:@"fetchStopWithId"
                                                              substitutionVariables:@{@"id" : stopId}];
    
    NSError *error = nil;
    NSArray* stops = [self.managedObjectContext executeFetchRequest:request error:&error];
    return ([stops count] == 0) ? nil : [stops objectAtIndex:0];
}

@end
