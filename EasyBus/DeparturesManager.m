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
#import "Route+Additions.h"
#import "Stop.h"
#import "Trip+Additions.h"
#import "NSManagedObjectContext+Network.h"
#import "NSManagedObjectContext+Trip.h"

@interface DeparturesManager()
@property (strong, nonatomic) NSMutableArray* departures;

@property(nonatomic) NSString* currentNode;
@property(nonatomic) NSString* stop;
@property(nonatomic) NSString* route;
@property(nonatomic) NSString* direction;
@property(nonatomic) NSString* headsign;
@property(nonatomic) NSString* currentDate;
@property(nonatomic) NSString* accurate;
@property(nonatomic) NSString* departureDate;

@property(nonatomic) NSDateFormatter* timeIntervalFormatter;
@property(nonatomic) NSDateFormatter* xsdDateTimeFormatter;

@property(nonatomic) AFHTTPRequestOperationManager* requestOperationManager;

@end

@implementation DeparturesManager
objection_register_singleton(DeparturesManager)
objection_requires(@"managedObjectContext")

//Déclaration des notifications
NSString* const departuresUpdateStartedNotification = @"departuresUpdateStartedNotification";
NSString* const departuresUpdateFailedNotification = @"departuresUpdateFailedNotification";
NSString* const departuresUpdateSucceededNotification = @"departuresUpdateSucceededNotification";

#pragma - Constructor & IoC
- (id)init {
    if ( self = [super init] ) {
        self.departures = [NSMutableArray new];

        self.timeIntervalFormatter = [[NSDateFormatter alloc] init];
        self.timeIntervalFormatter.timeStyle = NSDateFormatterFullStyle;
        self.timeIntervalFormatter.dateFormat = @"m";
    
        self.xsdDateTimeFormatter = [[NSDateFormatter alloc] init];  // Keep around forever
        self.xsdDateTimeFormatter.timeStyle = NSDateFormatterFullStyle;
        self.xsdDateTimeFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:sszzz";

        self.requestOperationManager = [AFHTTPRequestOperationManager manager];
        [self.requestOperationManager.operationQueue setMaxConcurrentOperationCount:1];
        self.requestOperationManager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        self.requestOperationManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/xml", @"text/xml"]];
        [self.requestOperationManager.operationQueue setMaxConcurrentOperationCount:1];
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
    return self.departures;
}

- (NSArray*) getDeparturesForTrips:(NSArray*)trips {
    NSMutableArray* departures = [[NSMutableArray alloc] init];
    [trips enumerateObjectsUsingBlock:^(Trip* trip, NSUInteger idx, BOOL *stop)
    {
        NSPredicate* routePredicate = [NSPredicate predicateWithFormat:@"stop.id == %@", trip.stop.id];
        NSPredicate* stopPredicate = [NSPredicate predicateWithFormat:@"route.id == %@", trip.route.id];
        NSPredicate* directionPredicate = [NSPredicate predicateWithFormat:@"direction == %@", trip.direction];
        NSPredicate* predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[routePredicate, stopPredicate, directionPredicate]];
        NSArray* partialResult = [self.departures filteredArrayUsingPredicate:predicate];
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
- (void)refreshDepartures {
    //Log
    NSLog(@"Departures update started");
    
    //Parsers XML
    NSMutableArray *xmlParsers = [NSMutableArray array];
    
    //Construction des requêtes (les Trips sont découpés par bloc de 10 maximum)
    NSMutableArray* trips = [[self.managedObjectContext trips] mutableCopy];
    NSMutableArray *requestsOperations = [NSMutableArray array];
    int requestCount = 0;
    while (trips.count > 0) {
        //Construction de la requête
        static NSString* PATH = @"http://data.keolis-rennes.com/xml/";
        static NSString* PARAM_ROUTE = @"param[route]";
        static NSString* PARAM_DIRECTION = @"param[direction]";
        static NSString* PARAM_STOP = @"param[stop]";

        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setObject:@"getbusnextdepartures" forKey:@"cmd"];
        [params setObject:@"2.1" forKey:@"version"];
        [params setObject:@"91RU2VSP13GHHOP" forKey:@"key"];
        [params setObject:@"stopline" forKey:@"param[mode]"];
        [params setObject:@"getbusnextdepartures" forKey:@"cmd"];
        
        NSMutableArray* paramsRoute = [[NSMutableArray alloc] init];
        NSMutableArray* paramsdirection = [[NSMutableArray alloc] init];
        NSMutableArray* paramsStop = [[NSMutableArray alloc] init];
        for (int i=0; i<10 && trips.count>0; i++) {
            Trip* trip = trips[0];
            //Exclusion de trips orphelins

#warning Voir pourquoi il y a des trips orphelins
            if (!trip.favoriteGroup && !trip.proximityGroup) {
                NSLog(@"ATTENTION : trips orphelins !!!");
                [self.managedObjectContext deleteObject:trip];
                [trips removeObject:trip];
                continue;
            }

            [paramsRoute addObject:trip.route.id];
            [paramsdirection addObject:trip.direction];
            [paramsStop addObject:trip.stop.id];
            [trips removeObject:trip];
        }
        [params setObject:paramsRoute forKey:PARAM_ROUTE];
        [params setObject:paramsdirection forKey:PARAM_DIRECTION];
        [params setObject:paramsStop forKey:PARAM_STOP];
        
        NSError* error;
        NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:PATH parameters:params error:&error];
        if (error) {
            NSLog(@"Request %i failed : %@", requestCount, [error debugDescription]);
        }
        else {
            AFHTTPRequestOperation *operation = [self.requestOperationManager HTTPRequestOperationWithRequest:request
                                      success:^(AFHTTPRequestOperation *operation, NSXMLParser* xmlParser) {
                                          [xmlParsers addObject:xmlParser];
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          //Log
                                          NSLog(@"Request %i failed : %@", requestCount, [error debugDescription]);
                                      }];

            [requestsOperations addObject:operation];
//            NSLog(@"Request %i : %@", requestCount, request.URL.absoluteString);
            requestCount++;
        }
    }
    
    //Lancement des requêtes
    if (requestsOperations.count > 0) {
        //Notification
        [[NSNotificationCenter defaultCenter] postNotificationName:departuresUpdateStartedNotification object:self];
        
        NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:requestsOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            //NSLog(@"%i/%i requests finished", numberOfFinishedOperations, totalNumberOfOperations);
        }
        completionBlock:^(NSArray *operations) {
            //Clean data
            self.departures = [[NSMutableArray alloc] init];
            
            //Parse responses
            [xmlParsers enumerateObjectsUsingBlock:^(NSXMLParser* xmlParser, NSUInteger idx, BOOL *stop) {
                [xmlParser setDelegate:self];
                [xmlParser parse];
            }];
            
            //Log
            NSLog(@"Departures update finished");
            
            //Notification
            [[NSNotificationCenter defaultCenter] postNotificationName:departuresUpdateSucceededNotification object:self];
        }];
        [self.requestOperationManager.operationQueue addOperations:operations waitUntilFinished:NO];
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
            [self.departures addObject:depart];
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
