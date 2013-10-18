//
//  UpdateManager.m
//  EasyBus
//
//  Created by Benoit on 09/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <AFNetworking/AFNetworking.h>
#import "GtfsUpdateManager.h"

@interface GtfsUpdateManager() <NSXMLParserDelegate>

@property(nonatomic, retain) NSDateFormatter* xsdDateTimeFormatter;
@property(nonatomic, retain) NSDateFormatter* xsdDateFormatter;
@property(nonatomic) BOOL isRequesting;
@property(nonatomic, retain) NSString* currentNode;
@property(nonatomic, retain) NSString * publishDate;
@property(nonatomic, retain) NSString * startDate;
@property(nonatomic, retain) NSString * endDate;
@property(nonatomic, retain) NSString * version;
@property(nonatomic, retain) NSString * url;

@end

@implementation GtfsUpdateManager
objection_register_singleton(GtfsUpdateManager)

objection_requires(@"managedObjectContext")
@synthesize managedObjectContext, publishEntry, publishDate, startDate, endDate, version, url;

//constructeur
-(id)init {
    if ( self = [super init] ) {
        self.xsdDateTimeFormatter = [[NSDateFormatter alloc] init];  // Keep around forever
        self.xsdDateTimeFormatter.timeStyle = NSDateFormatterFullStyle;
        self.xsdDateTimeFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:sszzz";

        self.xsdDateFormatter = [[NSDateFormatter alloc] init];  // Keep around forever
        self.xsdDateFormatter.dateFormat = @"yyyy-MM-dd";

        self.isRequesting = FALSE;
    }
    
    return self;
}

-(void)refreshData {
    if (!self.isRequesting) {
        //Lancement du traitement
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gtfsUpdateStarted" object:self];

        self.isRequesting = TRUE;
        self.publishDate = nil;
        self.startDate = nil;
        self.endDate = nil;
        self.version = nil;
        self.publishDate = nil;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        [manager GET:@"http://data.keolis-rennes.com/fileadmin/OpenDataFiles/GTFS/feed"
            parameters:nil
            success:^(AFHTTPRequestOperation *operation, NSXMLParser* xmlParser) {
                    //Parse response
                    [xmlParser setDelegate:self];
                    [xmlParser parse];
                
                //lance la notification departuresUpdated
                [[NSNotificationCenter defaultCenter] postNotificationName:@"gtfsUpdateSucceeded" object:self];
                self.isRequesting = FALSE;
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"Error: %@", error);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"gtfsUpdateFailed" object:self];
                self.isRequesting = FALSE;
            }];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gtfsUpdateSucceeded" object:self];
    }
}

#pragma mark NSXMLParserDelegate methods
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    //début du document
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.currentNode = elementName;
    if ([elementName isEqualToString:@"link"] && [attributeDict[@"rel"] isEqualToString:@"enclosure"]) {
        self.url = attributeDict[@"href"];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    _currentNode = nil;
    if ([elementName isEqualToString:@"entry"] ) {
        //fin d'un arrêt
        if (self.publishDate && self.startDate && self.endDate && self.version && self.url) {
            // Create and configure a new instance of the Route entity.
            NSDate* now = [NSDate date];
            NSDate* tmpStartDate = [_xsdDateFormatter dateFromString: self.startDate];
            NSDate* tmpEndDate = [_xsdDateFormatter dateFromString: self.endDate];

            if ([tmpStartDate compare:now] == NSOrderedAscending && [tmpEndDate compare:now] == NSOrderedDescending) {
                // Create and configure a new instance of GtfsPublishDataTmp.
                self.publishEntry = [[GtfsPublishDataTmp alloc] init];
                self.publishEntry.publishDate = [_xsdDateTimeFormatter dateFromString: self.publishDate];;
                self.publishEntry.startDate = tmpStartDate;
                self.publishEntry.endDate = tmpEndDate;
                self.publishEntry.version = self.version;
                self.publishEntry.url = self.url;
                
                //Stop parsing
                [parser abortParsing];
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([_currentNode isEqualToString:@"updated"] ) {
        //date de publication/update
        self.publishDate = string;
    }
    else if ([_currentNode isEqualToString:@"gtfs:start"] ) {
        //date de début de validité
        self.startDate = string;
    }
    else if ([_currentNode isEqualToString:@"gtfs:end"] ) {
        //date de début de validité
        self.endDate = string;
    }
    else if ([_currentNode isEqualToString:@"gtfs:version"] ) {
        self.version = string;
    }
}

@end
