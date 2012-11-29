//
//  DeparturesManager.h
//  EasyBus
//
//  Created by Benoit on 20/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Depart.h"
#import "Favorite.h"

@interface DeparturesManager : NSObject <NSXMLParserDelegate>

+ (DeparturesManager*) singleton;
- (NSArray*) getDepartures;
- (NSArray*) getDeparturesForGroupe:(Favorite*)groupe;
- (void) loadDeparturesFromKeolis:(NSArray*)favorites;

@property(nonatomic) NSMutableData* _receivedData;
@end
