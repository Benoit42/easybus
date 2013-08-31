//
//  FavoritesNavigationControler.m
//  EasyBus
//
//  Created by Benoit on 29/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "FavoritesNavigationController.h"

@implementation FavoritesNavigationController

@synthesize managedObjectContext;
@synthesize staticDataManager, favoritesManager;

@synthesize _currentFavoriteRoute;
@synthesize _currentFavoriteStop;
@synthesize _currentFavoriteDirection;

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize data
    NSManagedObjectModel* managedObjectModel = [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    self.staticDataManager = [[StaticDataManager alloc]initWithContext:self.managedObjectContext andModel:managedObjectModel];
}

@end
