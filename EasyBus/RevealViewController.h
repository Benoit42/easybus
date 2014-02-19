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

@property (nonatomic) UIViewController* departuresViewController;
@property (nonatomic) UIViewController* nearStopsController;
@property (nonatomic) UIViewController* favoritesViewController;
@property (nonatomic) UIViewController* linesViewController;
@property (nonatomic) UIViewController* creditsViewController;
@property (nonatomic) UIViewController* feedInfoViewController;

- (void) showDepartures;
- (void) showMap;
- (void) showLines;
- (void) showFavorites;
- (void) showCredits;
- (void) showFeedInfo;
- (void) showMenu;

@end
