//
//  StaticDataManager.h
//  EasyBus
//
//  Created by Benoit on 21/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StaticDataLoader : NSObject

- (id)initWithModel:(NSManagedObjectModel*)model andContext:(NSManagedObjectContext*) context;
- (void) loadData;

@end
