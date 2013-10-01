//
//  AppDelegate.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "AppDelegate.h"
#import "IoCModule.h"
#import "MainViewController.h"
#import "FavoritesManager.h"
#import "DeparturesManager.h"
#import "StaticDataManager.h"

@implementation AppDelegate

#pragma lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //IoC
    JSObjectionInjector *injector = [JSObjection createInjector:[[IoCModule alloc] init]];
    [JSObjection setDefaultInjector:injector];
    
    //Instanciation du Controleur racine
    //TODO : est-ce nécessaire ?
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    MainViewController *rootViewController = (MainViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"MainViewController"];
    self.window.rootViewController = rootViewController;
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    //sauvegarde du contexte
    NSManagedObjectContext* managedObjectContext = [[JSObjection defaultInjector] getObject:[NSManagedObjectContext class]];
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
    }    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    MainViewController *rootViewController = (MainViewController*)self.window.rootViewController;
    [rootViewController.locationManager startUpdatingLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //TODO : voir ce que l'on fait en cas d'erreur à l'init
}

@end
