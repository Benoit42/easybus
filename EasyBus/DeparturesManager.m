//
//  DeparturesManager.m
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "DeparturesManager.h"
#import "Favorite.h"

@interface DeparturesManager()
@property (strong, nonatomic) NSMutableArray* _departures;

@property(nonatomic) NSString* _currentNode;
@property(nonatomic) NSString* _stop;
@property(nonatomic) NSString* _route;
@property(nonatomic) NSString* _direction;
@property(nonatomic) NSString* _headsign;
@property(nonatomic) NSString* _currentDate;
@property(nonatomic) NSString* _departureDate;

@property(nonatomic) NSDateFormatter* _timeIntervalFormatter;
@property(nonatomic) NSDateFormatter* _xsdDateTimeFormatter;

@end

@implementation DeparturesManager
@synthesize _departures, _currentNode, _stop, _route, _direction, _headsign, _currentDate, _departureDate, _timeIntervalFormatter, _xsdDateTimeFormatter;

#pragma singleton & init
//instancie le singleton
+ (DeparturesManager *)singleton
{
    static DeparturesManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DeparturesManager alloc] init];
    });
    return sharedInstance;
}

//constructeur
-(id)init {
    if ( self = [super init] ) {
        _departures = [NSMutableArray new];
    }

    _timeIntervalFormatter = [[NSDateFormatter alloc] init];
    _timeIntervalFormatter.timeStyle = NSDateFormatterFullStyle;
    _timeIntervalFormatter.dateFormat = @"m";
    
    _xsdDateTimeFormatter = [[NSDateFormatter alloc] init];  // Keep around forever
    _xsdDateTimeFormatter.timeStyle = NSDateFormatterFullStyle;
    _xsdDateTimeFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:sszzz";

    return self;
}

#pragma manage departures
- (NSArray*) getDepartures {
    //retourne la liste des départs
    return _departures;
}

- (NSArray*) getDeparturesForGroupe:(Favorite*)groupe {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"arret == %@ && direction == %@", groupe.arret, groupe.direction];
    return [_departures filteredArrayUsingPredicate:predicate];
    //retourne la liste des départs
    return _departures;
}

#pragma call keolis and parse XML response
- (void) loadDeparturesFromKeolis:(NSArray*)favorites {
    @try {
        //met à jour la liste des départs
        [self getData:favorites];
    
        //lance la notification departuresUpdated
        [[NSNotificationCenter defaultCenter] postNotificationName:@"departuresUpdated" object:self];
    }
    @catch (NSException * e) {
        //Message d'alerte
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Erreur" message:@"Erreur lors de la récupération des départs" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)getData:(NSArray*)favorites {
        // Cleanup departures
        [_departures removeAllObjects];
    
        if ([favorites count] > 0 ) {
            // Create the request an parse the XML
            static NSString* basePath = @"http://data.keolis-rennes.com/xml/?cmd=getbusnextdepartures&version=2.1&key=91RU2VSP13GHHOP&param[mode]=stopline";
            static NSString* paramPath = @"&param[route][]=%@&param[direction][]=%@&param[stop][]=%@";
            
            //compute path
            NSMutableString* path = [[NSMutableString alloc] initWithString:basePath];
            for (int i=0; i<[favorites count] && i<10; i++) {
                //Get bus
                Favorite* bus = [favorites objectAtIndex:i];
                
                //Compute path
                [path appendFormat:paramPath, bus.ligne, bus.direction, bus.arret];
            }
            
            // Call Keolis
            NSData* xmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
            //NSString* filePath = [[NSBundle mainBundle] pathForResource:@"getbusnextdepartures" ofType:@"xml"];
            //NSData* xmlData = [NSData dataWithContentsOfFile:filePath];
            
            //Parse response
            NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
            [xmlParser setDelegate:self];
            [xmlParser parse];
            
            //Sort data
            //TODO a mettre dans le traitement de la vue
            NSArray* sortedDeparts = [_departures sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                return [(Depart*)a _delai] > [(Depart*)b _delai];
            }];
            [_departures removeAllObjects];
            [_departures addObjectsFromArray:sortedDeparts];
        }
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
            
            //création du départ
            Depart* depart = [[Depart alloc] initWithName:_route arret:_stop direction:_direction headsign:_headsign delai:interval];
            [_departures addObject:depart];
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
    // inform the user
    UIAlertView *didFailWithErrorMessage = [[UIAlertView alloc] initWithTitle:@"NSXMLParser" message:@"Erreur de traitement des horaires"  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [didFailWithErrorMessage show];
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
