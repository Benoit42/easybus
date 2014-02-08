//
//  FavoritesViewController.h
//  EasyBus
//
//  Created by Benoit on 13/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavoritesManager.h"
#import "GroupManager.h"

@interface FavoritesViewController : UITableViewController <UIGestureRecognizerDelegate>

@property(nonatomic) NSManagedObjectContext* managedObjectContext;
@property(nonatomic) FavoritesManager* favoritesManager;
@property(nonatomic) GroupManager* groupManager;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *modifyButton;

- (IBAction)modifyButtonPressed:(id)sender;

@end
