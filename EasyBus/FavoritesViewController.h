//
//  FavoritesViewController.h
//  EasyBus
//
//  Created by Benoit on 13/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoritesViewController : UITableViewController <UIGestureRecognizerDelegate>

@property(nonatomic) NSManagedObjectContext* managedObjectContext;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *modifyButton;

- (IBAction)modifyButtonPressed:(id)sender;

@end
