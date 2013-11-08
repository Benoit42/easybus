//
//  LinesNavigationControllerViewController.h
//  EasyBus
//
//  Created by Benoit on 07/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"
#import "Stop.h"

@interface LinesNavigationController : UINavigationController

@property(retain, nonatomic) Route* currentFavoriteRoute;
@property(retain, nonatomic) Stop* currentFavoriteStop;
@property(retain, nonatomic) NSString* currentFavoriteDirection;

@end
