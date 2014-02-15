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

@property(retain, nonatomic) Route* currentTripRoute;
@property(retain, nonatomic) Stop* currentTripStop;
@property(retain, nonatomic) NSString* currentTripDirection;

@end
