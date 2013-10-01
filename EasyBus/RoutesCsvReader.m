//
//  LineReader.m
//  EasyBus
//
//  Created by Benoit on 18/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CoreData/CoreData.h>
#import "RoutesCsvReader.h"
#import "CSVParser.h"
#import "Route.h"

@implementation RoutesCsvReader
objection_register_singleton(RoutesCsvReader)

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

- (void)receiveRecord:(NSDictionary *)aRecord {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    // Create and configure a new instance of the Route entity.
    Route* route = (Route *)[NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
    route.id = [aRecord objectForKey:@"route_id"];
    route.shortName = [aRecord objectForKey:@"route_short_name"];
    route.longName = [aRecord objectForKey:@"route_long_name"];
    
    //Calcul des libellés des départs et arrivée
    //Exemple : "Rennes (République) <> Acigné"
    //Split sur le <> et suppression de la partie entre parenthèses
    NSArray* subs = [route.longName componentsSeparatedByString:@"<>"];
    NSString* fromName = ([subs count] > 0) ? [subs objectAtIndex:0] : @"Départ inconnu";
    NSString* toName = ([subs count] > 1) ? [subs objectAtIndex:1] : @"Arrivée inconnue";
        
    subs = [fromName componentsSeparatedByString:@"("];
    fromName = ([subs count] > 0) ? [subs objectAtIndex:0] : fromName;
    fromName = [fromName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    
    subs = [toName componentsSeparatedByString:@"("];
    toName = ([subs count] > 0) ? [subs objectAtIndex:0] : toName;
    toName = [toName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];

    route.fromName = fromName;
    route.toName = toName;
}

@end
