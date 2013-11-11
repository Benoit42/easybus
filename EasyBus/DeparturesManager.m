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

@interface DeparturesManager()
@property (strong, nonatomic) NSMutableArray* _departures;

@property(nonatomic) NSString* _currentNode;
@property(nonatomic) NSString* _stop;
@property(nonatomic) NSString* _route;
@property(nonatomic) NSString* _direction;
@property(nonatomic) NSString* _headsign;
@property(nonatomic) NSString* _currentDate;
@property(nonatomic) NSString* accurate;
@property(nonatomic) NSString* _departureDate;
@property(nonatomic) NSMutableArray* _freshDepartures;

@property(nonatomic) NSDateFormatter* _timeIntervalFormatter;
@property(nonatomic) NSDateFormatter* _xsdDateTimeFormatter;

@end

@implementation DeparturesManager
objection_register_singleton(DeparturesManager)

objection_requires(@"staticDataManager")
@synthesize _departures, _currentNode, _stop, _route, _direction, _headsign, _currentDate, accurate, _departureDate, _receivedData, _timeIntervalFormatter, _xsdDateTimeFormatter, _isRequesting, _freshDepartures, _refreshDate, staticDataManager;

//Déclaration des notifications
NSString* const departuresUpdateStarted = @"departuresUpdateStarted";
NSString* const departuresUpdateFailed = @"departuresUpdateFailed";
NSString* const departuresUpdateSucceeded = @"departuresUpdateSucceeded";

//constructeur
-(id)init {
    if ( self = [super init] ) {
        //Préconditions
//        NSAssert(self.staticDataManager != nil, @"staticDataManager should not be nil");
        
        _departures = [NSMutableArray new];
        _freshDepartures = [NSMutableArray new];

        _timeIntervalFormatter = [[NSDateFormatter alloc] init];
        _timeIntervalFormatter.timeStyle = NSDateFormatterFullStyle;
        _timeIntervalFormatter.dateFormat = @"m";
    
        _xsdDateTimeFormatter = [[NSDateFormatter alloc] init];  // Keep around forever
        _xsdDateTimeFormatter.timeStyle = NSDateFormatterFullStyle;
        _xsdDateTimeFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:sszzz";
    
        _isRequesting = FALSE;
    }

    return self;
}

#pragma manage departures
- (NSArray*) getDepartures {
    //retourne la liste des départs
    return _departures;
}

- (NSArray*) getDeparturesForGroupe:(Group*)groupe {
    NSMutableArray* departures = [[NSMutableArray alloc] init];
    NSOrderedSet* favorites = groupe.favorites;
    [favorites enumerateObjectsUsingBlock:^(Favorite* favorite, NSUInteger idx, BOOL *stop)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stop.name == %@ && route.id == %@ && _direction == %@", favorite.stop.name, favorite.route.id, favorite.direction];
        NSArray* partialResult = [_departures filteredArrayUsingPredicate:predicate];
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
    if ([favorites count] == 0 || _isRequesting){
        return;
    }
    
    @try {
        //Appel réel vers kéolis
        _isRequesting = TRUE;
        
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
        [[NSNotificationCenter defaultCenter] postNotificationName:departuresUpdateStarted object:self];
        
        //New departures array
        [_freshDepartures removeAllObjects];
        
        [manager GET:path
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, NSXMLParser* xmlParser) {
                 //Parse response
                 [xmlParser setDelegate:self];
                 [xmlParser parse];
                 
                 //Sort data
                 NSArray* sortedDeparts = [_freshDepartures sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                     return [(Depart*)a _delai] > [(Depart*)b _delai];
                 }];
                 [_departures removeAllObjects];
                 [_departures addObjectsFromArray:sortedDeparts];
                 
                 //Notification
                 [[NSNotificationCenter defaultCenter] postNotificationName:departuresUpdateSucceeded object:self];

                 //End
                 self._isRequesting = FALSE;
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 //Log
                 NSLog(@"Error: %@", [error debugDescription]);

                 //lance la notification d'erreur
                 [[NSNotificationCenter defaultCenter] postNotificationName:departuresUpdateFailed object:self];
                 
                 //End
                 self._isRequesting = FALSE;
             }];
    }
    @catch (NSException * e) {
        //Log
        NSLog(@"Data parsing failed! Error - %@ %@", [e description], [e debugDescription]);

        //lance la notification d'erreur
        [[NSNotificationCenter defaultCenter] postNotificationName:departuresUpdateFailed object:self];

        //End
        self._isRequesting = FALSE;
    }
}

#pragma mark NSXMLParserDelegate methods
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    //début du document
    _currentDate = nil;
    _refreshDate = [NSDate date];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    _currentNode = elementName;
    if ([elementName isEqualToString:@"data"] ) {
        _currentDate = [attributeDict objectForKey:(@"localdatetime")];
    }
    else if ([elementName isEqualToString:@"stopline"] ) {
        //début d'un arrêt
        _route = _stop = _direction = nil;
    }
    else if ([elementName isEqualToString:@"departure"] ) {
        //début d'un départ
        _departureDate = nil;
        _headsign = [attributeDict objectForKey:(@"headsign")];
        accurate = attributeDict[@"accurate"];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    _currentNode = nil;
    if ([elementName isEqualToString:@"departure"] ) {
        //fin d'un arrêt
        if (_route && _stop && _direction &&_headsign && _departureDate && _currentDate) {
            //calcul du délai, avec remise à 0 si négatif
            NSDate* currentDate = [self xsdDateTimeToNSDate:_currentDate];
            NSDate* departureDate = [self xsdDateTimeToNSDate:_departureDate];
            NSTimeInterval interval = [departureDate timeIntervalSinceDate:currentDate];
            interval = interval <0 ? 0 : interval;
            BOOL isRealTime = [accurate isEqualToString:@"1"];
            
            //Recherche de la route et de l'arrêt
            Route* route = [self.staticDataManager routeForId:_route];
            Stop* stop = [self.staticDataManager stopForId:_stop];
            
            //création du départ
            Depart* depart = [[Depart alloc] initWithRoute:route stop:stop direction:_direction delai:interval heure:departureDate isRealTime:isRealTime];
            [_freshDepartures addObject:depart];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([_currentNode isEqualToString:@"stop"] ) {
        //id de l'arrêt
        _stop = string;
    }
    else if ([_currentNode isEqualToString:@"route"] ) {
        //id de l'arrêt
        _route = string;
    }
    else if ([_currentNode isEqualToString:@"direction"] ) {
        //id de l'arrêt
        _direction = string;
    }
    else if ([_currentNode isEqualToString:@"departure"] ) {
        _departureDate = string;
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    //lance la notification d'erreur
    [[NSNotificationCenter defaultCenter] postNotificationName:departuresUpdateFailed object:self];
    
    //Log
    NSLog(@"XML parsing failed! Error - %@ %@", [parseError description], [parseError debugDescription]);
}

- (NSDate*) xsdDateTimeToNSDate:(NSString*)dateTime {
    // Date formatters don't grok a single trailing Z, so make it "GMT".
    if ([dateTime hasSuffix: @"Z"]) {
        dateTime = [[dateTime substringToIndex: dateTime.length - 1]
                    stringByAppendingString: @"GMT"];
    }
    
    NSDate *date = [_xsdDateTimeFormatter dateFromString: dateTime];
    if (!date) NSLog(@"could not parse date '%@'", dateTime);
    
    return (date);
}

@end
