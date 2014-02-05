//
//  UpdateManager.m
//  EasyBus
//
//  Created by Benoit on 09/10/13.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <AFNetworking/AFNetworking.h>
#import <ZipArchive/ZipArchive.h>
#import "GtfsDownloadManager.h"
#import "FeedInfo.h"

@interface GtfsDownloadManager() <NSXMLParserDelegate>

@property(nonatomic, retain) NSDateFormatter* xsdDateTimeFormatter;
@property(nonatomic, retain) NSDateFormatter* xsdDateFormatter;
@property(nonatomic) BOOL isRequesting;
@property(nonatomic, retain) NSMutableArray* publishEntries;
@property(nonatomic, retain) NSString* currentNode;
@property(nonatomic, retain) NSString * publishDate;
@property(nonatomic, retain) NSString * startDate;
@property(nonatomic, retain) NSString * endDate;
@property(nonatomic, retain) NSString * version;
@property(nonatomic, retain) NSString * url;
@property(nonatomic, retain) NSMutableArray* cleanUpBlocks;
@end

@implementation GtfsDownloadManager
objection_register_singleton(GtfsDownloadManager)

//Déclaration des notifications
NSString* const gtfsUpdateStarted = @"gtfsUpdateStarted";
NSString* const gtfsUpdateSucceeded = @"gtfsUpdateSucceeded";
NSString* const gtfsUpdateFailed = @"gtfsUpdateFailed";

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

#pragma mark public methods

#pragma mark "private" methods
-(void)getGtfsDataForDate:(NSDate*)date withSuccessBlock:(void(^)(FeedInfoTmp*))success andFailureBlock:(void(^)(NSError* error))failure {
    //Préconditions
    NSParameterAssert(date != nil);
    
    //Chargement des données
    NSLog(@"Chargement des données de mise à jour");
    
    self.isRequesting = TRUE;
    self.publishDate = nil;
    self.startDate = nil;
    self.endDate = nil;
    self.version = nil;
    self.publishDate = nil;
    self.publishEntries = [[NSMutableArray alloc] init];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/atom-xml", @"text/xml"]];
    
    //succès
    self.isRequesting = TRUE;
    
    [manager GET:@"http://data.keolis-rennes.com/fileadmin/OpenDataFiles/GTFS/feed"
        parameters:nil
        success:^(AFHTTPRequestOperation *operation, NSXMLParser* xmlParser) {
                //Parse response
                [xmlParser setDelegate:self];
                [xmlParser parse];
            
                //Get correct entry
                __block FeedInfoTmp* newFeedInfo;
                [self.publishEntries enumerateObjectsUsingBlock:^(FeedInfoTmp* entry, NSUInteger idx, BOOL *stop) {
                    if ([entry.startDate compare:date] == NSOrderedAscending && [entry.endDate compare:date] == NSOrderedDescending) {
                        newFeedInfo = entry;
                        *stop = TRUE;
                    }
                }];

            //succès
            self.isRequesting = FALSE;
            success(newFeedInfo);
            
            //lance la notification departuresUpdated
            [[NSNotificationCenter defaultCenter] postNotificationName:gtfsUpdateSucceeded object:self];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //failure
            self.isRequesting = FALSE;
            NSLog(@"Error: %@", [error debugDescription]);
            failure(error);
        }];
}

-(void)downloadGtfsData:(NSURL*)urlToDownload withSuccessBlock:(void(^)(NSURL* outputPath))success andFailureBlock:(void(^)(NSError* error))failure {
    //Préconditions
    NSParameterAssert(urlToDownload != nil);
    
    //Chargement des routes
    NSLog(@"Chargement des données GTFS");
    
    //Download file
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:urlToDownload];
    
    //succès
    self.isRequesting = TRUE;
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil
                destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
                    return [documentsDirectoryPath URLByAppendingPathComponent:[targetPath lastPathComponent]];
                }
                completionHandler:^(NSURLResponse *response, NSURL *fileUrl, NSError *error) {
                    //Add clean-up block
                    id cleanUpBlock = ^(void) {
                        [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
                    };
                    [self.cleanUpBlocks addObject:[cleanUpBlock copy]];
                    
                    //Return response
                    if (!error) {
                        NSInteger statusCode = ((NSHTTPURLResponse*)response).statusCode;
                        if (statusCode == 200) {
                            //Décompression des données
                            [self unzipFile:fileUrl withSuccessBlock:^(NSURL *outputPath) {
                                success(outputPath);
                            } andFailureBlock:^(NSError *error) {
                                NSLog(@"Error: %@", [error debugDescription]);
                                failure(error);
                            }];
                        }
                        else {
                            error = [[NSError alloc] initWithDomain:@"Downloading" code:1 userInfo:@{@"reason": [NSString stringWithFormat:@"HTTP status code %i", statusCode]}];
                            NSLog(@"Error: %@", [error debugDescription]);
                            failure(error);
                        }
                    }
                    else {
                        NSLog(@"Error: %@", [error debugDescription]);
                        [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
                        failure(error);
                    }

                    self.isRequesting = FALSE;
                }];
    [downloadTask resume];
}

-(void)unzipFile:(NSURL*)zipFileUrl withSuccessBlock:(void(^)(NSURL* outputPath))success andFailureBlock:(void(^)(NSError* error))failure {
    //Préconditions
    NSAssert(zipFileUrl != nil, @"zipFilePath should not be nil");
    
    //Chargement des routes
    NSLog(@"Décompression des données GTFS");
    
    //Unzip file
    ZipArchive *za = [[ZipArchive alloc] init];

    NSString* zipFilePath = [zipFileUrl path];
    NSString* outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[zipFilePath lastPathComponent] stringByDeletingPathExtension]];
    if( [za UnzipOpenFile:zipFilePath] ) {
        if( [za UnzipFileTo:outputPath overWrite:YES] != NO ) {
            NSURL* outputUrl = [NSURL fileURLWithPath:outputPath];
            //Add clean-up block
            id cleanUpBlock = ^(void) {
                [[NSFileManager defaultManager] removeItemAtURL:outputUrl error:nil];
            };
            [self.cleanUpBlocks addObject:[cleanUpBlock copy]];

            //Return response
            success(outputUrl);
        }
        else {
            NSError* error = [[NSError alloc] initWithDomain:@"Unzipping" code:1 userInfo:@{@"reason": [NSString stringWithFormat:@"Unable to unzip %@", zipFilePath]}];
            NSLog(@"Error: %@", [error debugDescription]);
            failure(error);
        }
        
        [za UnzipCloseFile];
    }
    else {
        NSError* error = [[NSError alloc] initWithDomain:@"Unzipping" code:1 userInfo:@{@"reason": [NSString stringWithFormat:@"Unable to open zip file %@", zipFilePath]}];
        NSLog(@"Error: %@", [error debugDescription]);
        failure(error);
    }
}

- (void)cleanUp {
    NSArray* tmpArray = [NSArray arrayWithArray:self.cleanUpBlocks];
    [self.cleanUpBlocks removeAllObjects];
    [tmpArray enumerateObjectsUsingBlock:^(void(^cleanUpBlock)(void), NSUInteger idx, BOOL *stop) {
        cleanUpBlock();
    }];
}

#pragma mark NSXMLParserDelegate methods
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    //début du document
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    self.currentNode = elementName;
    if ([elementName isEqualToString:@"link"] && [attributeDict[@"rel"] isEqualToString:@"enclosure"]) {
        self.url = attributeDict[@"href"] ;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    _currentNode = nil;
    if ([elementName isEqualToString:@"entry"] ) {
        //fin d'un arrêt
        if (self.publishDate && self.startDate && self.endDate && self.version && self.url) {
            // Create and configure a new instance of GtfsPublishDataTmp.
            NSDate* tmpStartDate = [_xsdDateFormatter dateFromString: self.startDate]; //00:00:00
            NSDate* tmpEndDate = [_xsdDateFormatter dateFromString: self.endDate]; // 00:00:00 -> 23:59:59
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            [comps setDay:1];
            tmpEndDate = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:tmpEndDate  options:0];
            
            FeedInfoTmp* tmpPublishEntry = [[FeedInfoTmp alloc] init];
            tmpPublishEntry.publishDate = [_xsdDateTimeFormatter dateFromString: self.publishDate];;
            tmpPublishEntry.startDate = tmpStartDate;
            tmpPublishEntry.endDate = tmpEndDate;
            tmpPublishEntry.version = self.version;
            tmpPublishEntry.url = [NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [self.publishEntries addObject:tmpPublishEntry];
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
