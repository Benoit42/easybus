//
//  DeparturesManager.h
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Depart.h"
#import "Favorite+FavoriteWithAdditions.h"
#import "StaticDataManager.h"

@interface DeparturesManager : NSObject <NSXMLParserDelegate>

- (NSArray*) getDepartures;
- (NSArray*) getDeparturesForGroupe:(Favorite*)groupe;
- (void) refreshDepartures:(NSArray*)favorites;

@property (nonatomic, retain) StaticDataManager *staticDataManager;

@property(nonatomic) NSMutableData* _receivedData;
@property(nonatomic) BOOL _isRequesting;
@property(nonatomic) NSDate* _refreshDate;

@end
