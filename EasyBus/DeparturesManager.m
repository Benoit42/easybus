//
//  DeparturesManager.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <AFNetworking/AFNetworking.h>
#import "DeparturesManager.h"
#import "Route+RouteWithAdditions.h"
#import "Stop.h"
#import "Favorite+FavoriteWithAdditions.h"
#import "NSManagedObjectContext+Network.h"

@interface DeparturesManager()
@property (strong, nonatomic) NSMutableArray* _departures;

@property(nonatomic) NSString* currentNode;
@property(nonatomic) NSString* stop;
@property(nonatomic) NSString* route;
@property(nonatomic) NSString* direction;
@property(nonatomic) NSString* headsign;
@property(nonatomic) NSString* currentDate;
@property(nonatomic) NSString* accurate;
@property(nonatomic) NSString* departureDate;
@property(nonatomic) NSMutableArray* freshDepartures;

@property(nonatomic) NSDateFormatter* timeIntervalFormatter;
@property(nonatomic) NSDateFormatter* xsdDateTimeFormatter;

@end

@implementation DeparturesManager
objection_register_singleton(DeparturesManager)
objection_requires(@"managedObjectContext")

//Déclaration des notifications
NSString* const departuresUpdateStartedNotification = @"departuresUpdateStartedNotification";
NSString* const departuresUpdateFailedNotification = @"departuresUpdateFailedNotification";
NSString* const departuresUpdateSucceededNotification = @"departuresUpdateSucceededNotification";

#pragma - Constructor & IoC
-(id)init {
    if ( self = [super init] ) {
        self._departures = [NSMutableArray new];
        self.freshDepartures = [NSMutableArray new];

        self.timeIntervalFormatter = [[NSDateFormatter alloc] init];
        self.timeIntervalFormatter.timeStyle = NSDateFormatterFullStyle;
        self.timeIntervalFormatter.dateFormat = @"m";
    
        self.xsdDateTimeFormatter = [[NSDateFormatter alloc] init];  // Keep around forever
        self.xsdDateTimeFormatter.timeStyle = NSDateFormatterFullStyle;
        self.xsdDateTimeFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:sszzz";
    
        self._isRequesting = FALSE;
    }

    return self;
}

- (void)awakeFromObjection {
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext);
}

#pragma - Manage departures
- (NSArray*) getDepartures {
    //retourne la liste des départs
    return self._departures;
}

- (NSArray*) getDeparturesForGroupe:(Group*)groupe {
    NSMutableArray* departures = [[NSMutableArray alloc] init];
    NSOrderedSet* favorites = groupe.favorites;
    [favorites enumerateObjectsUsingBlock:^(Favorite* favorite, NSUInteger idx, BOOL *stop)
    {
        NSPredicate* routePredicate = [NSPredicate predicateWithFormat:@"stop.id == %@", favorite.stop.id];
        NSPredicate* stopPredicate = [NSPredicate predicateWithFormat:@"route.id == %@", favorite.route.id];
        NSPredicate* directionPredicate = [NSPredicate predicateWithFormat:@"direction == %@", favorite.direction];
        NSPredicate* predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[routePredicate, stopPredicate, directionPredicate]];
        NSArray* partialResult = [self._departures filteredArrayUsingPredicate:predicate];
        [departures addObjectsFromArray:partialResult];
    }];

    //tri
    NSArray *sortedDepartures = [departures sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSTimeInterval first = [(Depart*)a _delai];
        NSTimeInterval second = [(Depart*)b _delai];
        return first > second;
    }];

    //retourne la liste des départs
    return sortedDepartures;
}

#pragma call keolis and parse XML response
- (void)refreshDepartures:(NSArray*)favorites {
    //Controles
    if ([favorites count] == 0 || self._isRequesting){
        return;
    }
    
    @synchronized(self) {
        @try {
            //Appel réel vers kéolis
            self._isRequesting = TRUE;
            
            // Create the request an parse the XML
            static NSString* basePath = @"http://data.keolis-rennes.com/xml/?cmd=getbusnextdepartures&version=2.1&key=91RU2VSP13GHHOP&param[mode]=stopline";
            static NSString* paramPath = @"&param[route][]=%@&param[direction][]=%@&param[stop][]=%@";
            
            //compute path
            NSMutableString* path = [[NSMutableString alloc] initWithString:basePath];
            for (int i=0; i<[favorites count] && i<10; i++) {
                //Get bus
                Favorite* favorite = [favorites objectAtIndex:i];
                
                //Compute path
                [path appendFormat:paramPath, favorite.route.id, favorite.direction, favorite.stop.id];
            }
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/xml", @"text/xml"]];
            
            //Lancement du traitement
            [[NSNotificationCenter defaultCenter] postNotificationName:departuresUpdateStartedNotification object:self];
            
            //New departures array
            [self.freshDepartures removeAllObjects];
            
            [manager GET:path
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, NSXMLParser* xmlParser) {
                     //Parse response
                     [xmlParser setDelegate:self];
                     [xmlParser parse];
                     
                     //Store data
                     self._departures = self.freshDepartures;
                     
                     //Notification
                     [[NSNotificationCenter defaultCenter] postNotificationName:departuresUpdateSucceededNotification object:self];

                     //End
                     self._isRequesting = FALSE;
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     //Log
                     NSLog(@"Error: %@", [error debugDescription]);

                     //lance la notification d'erreur
                     [[NSNotificationCenter defaultCenter] postNotificationName:departuresUpdateFailedNotification object:self];
                     
                     //End
                     self._isRequesting = FALSE;
                 }];
        }
        @catch (NSException * e) {
            //Log
            NSLog(@"Data parsing failed! Error - %@ %@", [e description], [e debugDescription]);

            //lance la notification d'erreur
            [[NSNotificationCenter defaultCenter] postNotificationName:departuresUpdateFailedNotification object:self];

            //End
            self._isRequesting = FALSE;
        }
    }
}

#pragma mark NSXMLParserDelegate methods
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    //début du document
    self.currentDate = nil;
    self._refreshDate = [NSDate date];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.currentNode = elementName;
    if ([elementName isEqualToString:@"data"] ) {
        self.currentDate = [attributeDict objectForKey:(@"localdatetime")];
    }
    else if ([elementName isEqualToString:@"stopline"] ) {
        //début d'un arrêt
        self.route = self.stop = self.direction = nil;
    }
    else if ([elementName isEqualToString:@"departure"] ) {
        //début d'un départ
        self.departureDate = nil;
        self.headsign = [attributeDict objectForKey:(@"headsign")];
        self.accurate = attributeDict[@"accurate"];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    self.currentNode = nil;
    if ([elementName isEqualToString:@"departure"] ) {
        //fin d'un arrêt
        if (self.route && self.stop && self.direction && self.headsign && self.departureDate && self.currentDate) {
            //calcul du délai, avec remise à 0 si négatif
            NSDate* currentDate = [self xsdDateTimeToNSDate:self.currentDate];
            NSDate* departureDate = [self xsdDateTimeToNSDate:self.departureDate];
            NSTimeInterval interval = [departureDate timeIntervalSinceDate:currentDate];
            interval = interval <0 ? 0 : interval;
            BOOL isRealTime = [self.accurate isEqualToString:@"1"];
            
            //Recherche de la route et de l'arrêt
            Route* route = [self.managedObjectContext routeForId:self.route];
            Stop* stop = [self.managedObjectContext stopForId:self.stop];
            
            //création du départ
            Depart* depart = [[Depart alloc] initWithRoute:route stop:stop direction:self.direction delai:interval heure:departureDate isRealTime:isRealTime];
            [self.freshDepartures addObject:depart];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([self.currentNode isEqualToString:@"stop"] ) {
        //id de l'arrêt
        self.stop = string;
    }
    else if ([self.currentNode isEqualToString:@"route"] ) {
        //id de l'arrêt
        self.route = string;
    }
    else if ([self.currentNode isEqualToString:@"direction"] ) {
        //id de l'arrêt
        self.direction = string;
    }
    else if ([self.currentNode isEqualToString:@"departure"] ) {
        self.departureDate = string;
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    //lance la notification d'erreur
    [[NSNotificationCenter defaultCenter] postNotificationName:departuresUpdateFailedNotification object:self];
    
    //Log
    NSLog(@"XML parsing failed! Error - %@ %@", [parseError description], [parseError debugDescription]);
}

- (NSDate*) xsdDateTimeToNSDate:(NSString*)dateTime {
    // Date formatters don't grok a single trailing Z, so make it "GMT".
    if ([dateTime hasSuffix: @"Z"]) {
        dateTime = [[dateTime substringToIndex: dateTime.length - 1]
                    stringByAppendingString: @"GMT"];
    }
    
    NSDate *date = [self.xsdDateTimeFormatter dateFromString: dateTime];
    if (!date) NSLog(@"could not parse date '%@'", dateTime);
    
    return (date);
}

@end
