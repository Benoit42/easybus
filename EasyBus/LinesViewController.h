//
//  FlipsideViewController.h
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoritesManager.h"
#import "GtfsDownloadManager.h"

@interface LinesViewController : UITableViewController

@property(nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic) FavoritesManager* favoritesManager;
@property(nonatomic) GtfsDownloadManager* gtfsDownloadManager;

@end
