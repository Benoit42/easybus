//
//  RevealViewController.h
//  EasyBus
//
//  Created by Benoit on 05/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <SWRevealViewController/SWRevealViewController.h>

@interface RevealViewController : SWRevealViewController

@property(nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) UIViewController* menuViewController;
@property (nonatomic) UIViewController* departuresPageViewController;
@property (nonatomic) UIViewController* favoritesNavigationController;
@property (nonatomic) UIViewController* linesNavigationController;
@property (nonatomic) UIViewController* creditsNavigationController;
@property (nonatomic) UIViewController* feedInfoNavigationViewController;

- (void) showDepartures;
- (void) showLines;
- (void) showFavorites;
- (void) showCredits;
- (void) showFeedInfo;
- (void) showMenu;

@end
