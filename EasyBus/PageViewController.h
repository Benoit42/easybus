//
//  PageViewController.h
//  EasyBus
//
//  Created by Benoit on 26/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoritesManager.h"

@interface PageViewController : UIPageViewController <UIPageViewControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) FavoritesManager *favoritesManager;

@end
