//
//  LineReader.m
//  EasyBus
//
//  Created by Benoit on 18/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <CoreData/CoreData.h>
#import <CHCSVParser/CHCSVParser.h>
#import "RoutesCsvReader.h"
#import "Route.h"

@interface RoutesCsvReader() <CHCSVParserDelegate>

@property (nonatomic, strong) NSMutableArray* row;

@end

@implementation RoutesCsvReader
objection_register_singleton(RoutesCsvReader)

objection_requires(@"managedObjectContext")
@synthesize managedObjectContext;

- (void)loadData {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    //Chargement des routes
    NSLog(@"Chargement des routes");
    
    //parsing du fichier
    //Pourquoi ça ne marche pas avec initWithContentsOfCSVFile ???
    self.row = [[NSMutableArray alloc] init];
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"routes" withExtension:@"txt"];
    CHCSVParser * p = [[CHCSVParser alloc] initWithContentsOfCSVFile:[url path]];
    p.sanitizesFields = YES;
    [p setDelegate:self];
    [p parse];

    //parsing du fichier
    url = [[NSBundle mainBundle] URLForResource:@"routes_additionals" withExtension:@"txt"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        p = [[CHCSVParser alloc] initWithContentsOfCSVFile:[url path]];
        p.sanitizesFields = YES;
        [p setDelegate:self];
        [p parse];
    }
}

#pragma mark CHCSVParserDelegate methods
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    [self.row removeAllObjects];
}

- (void) parser:(CHCSVParser *)parser didEndLine:(NSUInteger)lineNumber {
    if (lineNumber > 1 && self.row.count == 3) {
        // Create and configure a new instance of the Route entity.
        Route* route = (Route *)[NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
        route.id = self.row[0];
        route.shortName = self.row[1];
        route.longName = self.row[2];
        
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
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    // route_id,agency_id,route_short_name,route_long_name,route_desc,route_type,route_url,route_color,route_text_color
    if (fieldIndex == 0 || fieldIndex == 2 || fieldIndex == 3) {
        [self.row addObject:field];
    }
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"TripsCsvReader parser failed with error: %@ %@", [error localizedDescription], [error userInfo]);
}

- (void)cleanUp {
    //nothing
}

@end
