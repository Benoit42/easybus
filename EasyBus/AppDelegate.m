//
//  AppDelegate.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "FavoritesManager.h"
#import "DeparturesManager.h"
#import "StaticDataManager.h"

@interface AppDelegate()

@property (nonatomic, retain) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@end

@implementation AppDelegate

#pragma lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Instanciation du contexte
    self.managedObjectModel = [self getManagedObjectModel];
    self.managedObjectContext = [self getManagedObjectContext];
    
    //Instanciation du Controleur racine
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    MainViewController *rootViewController = (MainViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"MainViewController"];
    self.window.rootViewController = rootViewController;
    
    //Initialisation du controleur racine
    rootViewController.managedObjectContext = self.managedObjectContext;
    rootViewController.favoritesManager = [[FavoritesManager alloc] initWithContext:self.managedObjectContext];
    rootViewController.groupManager = [[GroupManager alloc] initWithContext:self.managedObjectContext];
    rootViewController.staticDataManager = [[StaticDataManager alloc] initWithContext:self.managedObjectContext];
    rootViewController.departuresManager = [[DeparturesManager alloc] initWithStaticDataManager:rootViewController.staticDataManager];
    rootViewController.locationManager = [[LocationManager alloc] init];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    MainViewController *rootViewController = (MainViewController*)self.window.rootViewController;
    [rootViewController.locationManager startUpdatingLocation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    //sauvegarde du contexte
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma context management
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) getManagedObjectContext {
	
    if (self.managedObjectContext != nil) {
        return self.managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self getPersistentStoreCoordinator];
    if (coordinator != nil) {
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self.managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return self.managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)getManagedObjectModel {
    if (self.managedObjectModel != nil) {
        return self.managedObjectModel;
    }

    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return self.managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)getPersistentStoreCoordinator {
    if (self.persistentStoreCoordinator != nil) {
        return self.persistentStoreCoordinator;
    }

    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"data.sqlite"]];
    //[[NSFileManager defaultManager] removeItemAtURL:storeUrl error:NULL];
	NSError *error;
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        //Log
        NSLog(@"Database error - %@ %@", [error description], [error debugDescription]);
        [[NSFileManager defaultManager] removeItemAtURL:storeUrl error:NULL];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Erreur" message:@"Erreur lors du chargement, effacement des données" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
	
    return self.persistentStoreCoordinator;
}

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

#pragma UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //TODO : voir ce que l'on fait en cas d'erreur à l'init
}

@end
