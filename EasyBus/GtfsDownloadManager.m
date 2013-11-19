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

@property(nonatomic, retain) NSURL * downloadUrl;

@end

@implementation GtfsDownloadManager
objection_register_singleton(GtfsDownloadManager)

objection_requires(@"managedObjectContext", @"staticDataLoader")

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
-(void)checkUpdateWithDate:(NSDate*)date withSuccessBlock:(void(^)(BOOL))success andFailureBlock:(void(^)(NSError* error))failure {
    //Controles
    if (self.isRequesting) {
        return;
    }
    
    //Chargement en cours
    self.isRequesting = TRUE;
    
    @try {
        //Get GTFS file infos
        [self refreshPublishDataForDate:date
        withSuccessBlock:^(FeedInfoTmp* newFeedInfo) {
            //Check if update needed
            self.downloadUrl = newFeedInfo.url;
            BOOL updateNeeded =  (newFeedInfo) && (newFeedInfo.url) && (([date compare:newFeedInfo.startDate] == NSOrderedDescending)|| ([date compare:newFeedInfo.endDate] == NSOrderedAscending));
            success(updateNeeded);

            //End
            self.isRequesting = FALSE;
        }
        andFailureBlock:^(NSError *error) {
             //End
             self.isRequesting = FALSE;
             failure(error);
             
             //Log
             NSLog(@"Error: %@", [error debugDescription]);
        }];
    }
    @catch (NSException *exception) {
        //End
        self.isRequesting = FALSE;
        NSError* error = [[NSError alloc] initWithDomain:@"Checking update" code:1 userInfo:@{@"reason": [exception debugDescription]}];
        failure(error);
        
        //Log
        NSLog(@"Exception: %@", [exception debugDescription]);
    }
}

-(void)downloadDataWithSuccessBlock:(void(^)())success andFailureBlock:(void(^)(NSError* error))failure {
    //Préconditions
    NSParameterAssert(self.downloadUrl != nil);
    
    //Non concurrence
    if (self.isRequesting) {
        return;
    }
    
    //Chargement en cours
    [[NSNotificationCenter defaultCenter] postNotificationName:gtfsUpdateStarted object:self];
    self.isRequesting = TRUE;

    @try {
        //Download update
        [self downloadFile:self.downloadUrl
            withSuccessBlock:^(NSURL *zipFileUrl) {
                //Unzip GTFS data
                [self unzipFile:zipFileUrl
                    withSuccessBlock:^(NSURL *outputDirectory) {
                        //Process GTFS data
                        [self.staticDataLoader loadDataFromWeb:outputDirectory];

                        //End
                        [[NSNotificationCenter defaultCenter] postNotificationName:gtfsUpdateSucceeded object:self];
                        self.isRequesting = FALSE;
                        success();
                        
                        //CleanUp
                        [[NSFileManager defaultManager]removeItemAtURL:zipFileUrl error:nil];
                        [[NSFileManager defaultManager] removeItemAtURL:outputDirectory error:nil];
                        
                    } andFailureBlock:^(NSError *error) {
                        //CleanUp
                        [[NSFileManager defaultManager]removeItemAtURL:zipFileUrl error:nil];
                        
                        //End
                        [[NSNotificationCenter defaultCenter] postNotificationName:gtfsUpdateFailed object:self];
                        self.isRequesting = FALSE;
                        failure(error);
                    }];
            } andFailureBlock:^(NSError *error) {
                //End
                [[NSNotificationCenter defaultCenter] postNotificationName:gtfsUpdateFailed object:self];
                self.isRequesting = FALSE;
                failure(error);
            }];
    }
    @catch (NSException *exception) {
        //End
        NSLog(@"Exception: %@", [exception debugDescription]);
        [[NSNotificationCenter defaultCenter] postNotificationName:gtfsUpdateFailed object:self];
        self.isRequesting = FALSE;
        
        NSError* error = [[NSError alloc] initWithDomain:@"Loading GTFS data" code:1 userInfo:@{@"reason": [exception debugDescription]}];
        failure(error);
    }
}

#pragma mark "private" methods
-(void)refreshPublishDataForDate:(NSDate*)date withSuccessBlock:(void(^)(FeedInfoTmp*))success andFailureBlock:(void(^)(NSError* error))failure {
    //Préconditions
    NSAssert(date != nil, @"date should not be nil");
    
    //Chargement des routes
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
                        stop = TRUE;
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
            NSLog(@"Error: %@", [error debugDescription]);
            failure(error);
        }];
}

-(void)downloadFile:(NSURL*)urlToDownload withSuccessBlock:(void(^)(NSURL* fileUrl))success andFailureBlock:(void(^)(NSError* error))failure {
    //Préconditions
    NSAssert(urlToDownload != nil, @"fileUrl should not be nil");
    
    //Chargement des routes
    NSLog(@"Chargement des données GTFS");
    
    //Download file
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:urlToDownload];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil
                                                            destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
                                                                return [documentsDirectoryPath URLByAppendingPathComponent:[targetPath lastPathComponent]];
                                                            }
                                                            completionHandler:^(NSURLResponse *response, NSURL *fileUrl, NSError *error) {
                                                                if (!error) {
                                                                    NSInteger statusCode = ((NSHTTPURLResponse*)response).statusCode;
                                                                    if (statusCode == 200) {
                                                                        success(fileUrl);
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
