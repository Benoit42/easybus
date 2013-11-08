//
//  Constants.m
//  EasyBus
//
//  Created by Benoit on 07/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "Constants.h"

static UIColor* starGreenColorInstance = nil;

@implementation Constants
    
+(void) initialize
{
    starGreenColorInstance = [UIColor colorWithRed:69.0f/255.0f green:231.0f/255.0f blue:187.0f/255.0f alpha:1.0f];
}

+ (UIColor *)starGreenColor {
    return starGreenColorInstance;
}

@end
