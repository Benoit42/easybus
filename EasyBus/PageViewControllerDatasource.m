//
//  PageViewControlerDatasource.m
//  EasyBus
//
//  Created by Benoit on 18/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "PageViewControllerDatasource.h"
#import "DeparturesNavigationController.h"
#import "NearStopsNavigationController.h"
#import "NSManagedObjectContext+Group.h"

@interface PageViewControllerDatasource()

@property(nonatomic) NSMutableDictionary* departuresViewControlers;

@end

@implementation PageViewControllerDatasource
objection_register(PageViewControllerDatasource);
objection_requires(@"managedObjectContext", @"locationManager")

#pragma - Constructor & IoC
- (id)init {
    if ( self = [super init] ) {
        self.departuresViewControlers = [NSMutableDictionary new];
    }
    return self;
}

- (void)awakeFromObjection {
    //Pré-conditions
    NSParameterAssert(self.managedObjectContext);
    NSParameterAssert(self.locationManager);
}

#pragma - Autres

- (DeparturesNavigationController *)viewControllerForGroup:(Group*)group storyboard:(UIStoryboard *)storyboard {
    //Search if group already have a view controller
    DeparturesNavigationController* viewController = self.departuresViewControlers[group.objectID];
    if (viewController == nil) {
        //Le view controler n'existe pas encore
        if ([group.isNearStopGroup boolValue] == YES /* && self.locationManager.currentLocation*/) {
            //Groupe des arrêts proche (uniquement si la géoloc a été obtenue)
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"NearStopsNavigationController"];
            ((NearStopsNavigationController*)viewController).group = group;
        }
        else {
            //Groupe de favoris
            viewController = [storyboard instantiateViewControllerWithIdentifier:@"DeparturesNavigationController"];
            ((DeparturesNavigationController*)viewController).group = group;
        }
        
        [self.departuresViewControlers setObject:viewController forKey:group.objectID];
        
        //TODO:register to group notifications (when deleted) 
}
    
    return viewController;
}

#pragma mark - Page View Controller Data Source
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    //Recherche du groupe courant
    //TODO : il faudrait mettre un protocol pour la propriété group
    Group* group = ((DeparturesNavigationController*)viewController).group;
    int index = [[self.managedObjectContext allGroups] indexOfObject:group];
    
    //Recherche du groupe précédent
    if (index > 0) {
        Group* previousGroup = [self.managedObjectContext allGroups][--index];
        return [self viewControllerForGroup:previousGroup storyboard:viewController.storyboard];
    }
    else {
        return nil;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    //Recherche du groupe courant
    //TODO : il faudrait mettre un protocol pour la propriété group
    Group* group = ((DeparturesNavigationController*)viewController).group;
    NSArray* allGroups = [self.managedObjectContext allGroups];
    int index = [allGroups indexOfObject:group];
    
    //Recherche du groupe suivant
    if (index < allGroups.count - 1) {
        Group* followingGroup = [self.managedObjectContext allGroups][++index];
        return [self viewControllerForGroup:followingGroup storyboard:viewController.storyboard];
    }
    else {
        return nil;
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    int count = [[self.managedObjectContext allGroups] count];
    return count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    //Recherche du groupe courant
    //TODO : il faudrait mettre un protocol pour la propriété group
    Group* group = ((DeparturesNavigationController*)[pageViewController.viewControllers objectAtIndex:0]).group;
    int index = [[self.managedObjectContext allGroups] indexOfObject:group];
    if (index == NSNotFound) {
        return 0;
    }
    else {
        return index;
    }
}

@end
