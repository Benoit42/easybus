//
//  DeparturesManager.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

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
@property(nonatomic) NSString* _departureDate;
@property(nonatomic) NSMutableArray* _freshDepartures;

@property(nonatomic) NSDateFormatter* _timeIntervalFormatter;
@property(nonatomic) NSDateFormatter* _xsdDateTimeFormatter;

@end

@implementation DeparturesManager
@synthesize _departures, _currentNode, _stop, _route, _direction, _headsign, _currentDate, _departureDate, _receivedData, _timeIntervalFormatter, _xsdDateTimeFormatter, _isRequesting, _freshDepartures, _refreshDate, staticDataManager;

//constructeur
-(id)initWithStaticDataManager:(StaticDataManager*)staticDataManager_ {
    if ( self = [super init] ) {
        self.staticDataManager = staticDataManager_;
        
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
        //Lancement du traitement
        [[NSNotificationCenter defaultCenter] postNotificationName:@"departuresUpdateStarted" object:self];
        
        // Call Keolis
        BOOL real = TRUE;
        if (real) {
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
            
            //Send request
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:path]
                                                      cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                  timeoutInterval:60.0];
            NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
            if (theConnection) {
                // Create the NSMutableData to hold the received data.
                // receivedData is an instance variable declared elsewhere.
                _receivedData = [NSMutableData new];
            } else {
                //lance la notification d'erreur
                @throw [NSException
                 exceptionWithName:@"ConnectionException"
                 reason:@"Unable to contact Keolis server"
                 userInfo:nil];
            }
        }
        else {
            //Utilisation d'un fichier pour les tests
            NSString* filePath = [[NSBundle mainBundle] pathForResource:@"getbusnextdepartures" ofType:@"xml"];
            NSData* xmlData = [NSData dataWithContentsOfFile:filePath];
            [self parseData:xmlData];
            
            //lance la notification departuresUpdated
            [[NSNotificationCenter defaultCenter] postNotificationName:@"departuresUpdateSucceeded" object:self];
        }
    }
    @catch (NSException * e) {
        //lance la notification d'erreur
        [[NSNotificationCenter defaultCenter] postNotificationName:@"departuresUpdateFailed" object:self];

        //Request is not running
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        _isRequesting = FALSE;
        
        //Log
        NSLog(@"Data parsing failed! Error - %@ %@", [e description], [e debugDescription]);
    }
}

#pragma mark NSURLConnection methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //lance la notification d'erreur
    [[NSNotificationCenter defaultCenter] postNotificationName:@"departuresUpdateFailed" object:self];

    //Request is not running
    _isRequesting = FALSE;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    //Log
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    @try {
        //Network is not running
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        //Parse received data
        [self parseData:_receivedData];
        
        //lance la notification departuresUpdated
        [[NSNotificationCenter defaultCenter] postNotificationName:@"departuresUpdateSucceeded" object:self];
    }
    @catch (NSException *exception) {
        //lance la notification d'erreur
        [[NSNotificationCenter defaultCenter] postNotificationName:@"departuresUpdateFailed" object:self];
    
        //Log
        NSLog(@"Data parsing failed! Error - %@ %@", [exception description], [exception debugDescription]);
    }
    @finally {
        //Request is not running
        _isRequesting = FALSE;
    }
}

#pragma mark XML parsing
- (void)parseData:(NSData *)data
{
    //New departures array
    [_freshDepartures removeAllObjects];
        
    //Parse response
    NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:data];
    [xmlParser setDelegate:self];
    [xmlParser parse];
    
    //Sort data
    NSArray* sortedDeparts = [_freshDepartures sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [(Depart*)a _delai] > [(Depart*)b _delai];
    }];
    [_departures removeAllObjects];
    [_departures addObjectsFromArray:sortedDeparts];
}

#pragma mark NSXMLParserDelegate methods
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    //début du document
    _currentDate = nil;
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
            
            //Recherche de la route et de l'arrêt
            Route* route = [self.staticDataManager routeForId:_route];
            Stop* stop = [self.staticDataManager stopForId:_stop];
            
            //création du départ
            Depart* depart = [[Depart alloc] initWithRoute:route stop:stop direction:_direction delai:interval heure:departureDate];
            [_freshDepartures addObject:depart];
            
            _refreshDate = [NSDate date];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"departuresUpdateFailed" object:self];
    
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
