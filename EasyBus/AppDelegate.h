//
//  AppDelegate.h
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIWindow *window;

@end
