//
//  DeparturesManager.h
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Depart.h"
#import "Group.h"

@interface DeparturesManager : NSObject <NSXMLParserDelegate>

FOUNDATION_EXPORT NSString* const departuresUpdateStartedNotification;
FOUNDATION_EXPORT NSString* const departuresUpdateFailedNotification;
FOUNDATION_EXPORT NSString* const departuresUpdateSucceededNotification;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@property(nonatomic) NSMutableData* _receivedData;
@property(nonatomic) BOOL _isRequesting;
@property(nonatomic) NSDate* _refreshDate;

- (NSArray*) getDepartures;
- (NSArray*) getDeparturesForGroupe:(Group*)groupe;
- (void) refreshDepartures:(NSArray*)favorites;

@end
