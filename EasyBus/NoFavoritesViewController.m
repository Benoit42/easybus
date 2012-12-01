//
//  NoFavoritesViewController.m
//  EasyBus
//
//  Created by Benoit on 01/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "NoFavoritesViewController.h"
#import "FavoritesManager.h"
#import "DeparturesManager.h"

@implementation NoFavoritesViewController

#pragma mark - Segues
- (IBAction)unwindFromAlternate:(UIStoryboardSegue *)segue {
    //Rechargement des départs
    NSArray* favorite = [[FavoritesManager singleton] favorites];
    [[DeparturesManager singleton] refreshDepartures:favorite];
}

@end
