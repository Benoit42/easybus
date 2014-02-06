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
#import "FeedInfoCsvReader.h"

@interface FeedInfoCsvReader() <CHCSVParserDelegate>

@property (nonatomic, strong) NSMutableArray* row;
@end

@implementation FeedInfoCsvReader
objection_register_singleton(FeedInfoCsvReader)
objection_requires(@"managedObjectContext")

- (void)loadData:(NSURL*)url {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    //Log
    NSLog(@"Chargement des infos de données");
    
    //Initialisation du progress
    self.progress = [NSProgress progressWithTotalUnitCount:1]; //approx
    
    //parsing du fichier
    self.row = [[NSMutableArray alloc] init];
    NSInputStream *fileStream = [NSInputStream inputStreamWithFileAtPath:[url path]];
    NSStringEncoding encoding = NSUTF8StringEncoding;
    CHCSVParser * p = [[CHCSVParser alloc] initWithInputStream:fileStream usedEncoding:&encoding delimiter:','];
    p.sanitizesFields = YES;
    [p setDelegate:self];
    [p parse];
}

#pragma mark CHCSVParserDelegate methods
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    [self.row removeAllObjects];
}

- (void) parser:(CHCSVParser *)parser didEndLine:(NSUInteger)lineNumber {
    [self.progress setCompletedUnitCount:lineNumber];
    if (lineNumber > 1 && self.row.count == 6) {
        //Get feed info in database
        FeedInfo* feedInfo = [self feedInfo];
        if (feedInfo == nil) {
            feedInfo = (FeedInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"FeedInfo" inManagedObjectContext:self.managedObjectContext];
        }
        
        //Date formatter
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyyMMdd";

        feedInfo.publishDate = nil;
        feedInfo.startDate = [dateFormatter dateFromString:self.row[3]];
        feedInfo.endDate = [dateFormatter dateFromString:self.row[4]];
        feedInfo.version = self.row[5];
    }
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    // feed_publisher_name,feed_publisher_url,feed_lang,feed_start_date,feed_end_date,feed_version
    [self.row addObject:field];
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"FeedInfoCsvReader parser failed with error: %@ %@", [error localizedDescription], [error userInfo]);
}

- (void)cleanUp {
    //Nothing
}

- (FeedInfo*) feedInfo {
    //Pré-conditions
    NSAssert(self.managedObjectContext != nil, @"managedObjectContext should not be nil");
    
    NSManagedObjectModel *managedObjectModel = self.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
    NSFetchRequest *request = [managedObjectModel fetchRequestTemplateForName:@"fetchFeedInfo"];
    
    NSError *error = nil;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }
    if (fetchResults == nil) {
        //Log
        NSLog(@"Error, resultSet should not be nil");
    }
    
    return (fetchResults.count>0)?fetchResults[0]:nil;
}

@end
