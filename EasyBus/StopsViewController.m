//
//  StopsViewControler.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "StopsViewController.h"
#import "LinesNavigationController.h"
#import "StopCell.h"
#import "NSManagedObjectContext+Network.h"

@implementation StopsViewController
objection_requires(@"managedObjectContext")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //get the current route and direction
    Route* route = ((LinesNavigationController*)self.navigationController).currentTripRoute;
    NSString* direction = ((LinesNavigationController*)self.navigationController).currentTripDirection;
    
    // Return the number of rows in the section
    return [[self.managedObjectContext stopsForRoute:route direction:direction] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //get the current route and direction
    Route* route = ((LinesNavigationController*)self.navigationController).currentTripRoute;
    NSString* direction = ((LinesNavigationController*)self.navigationController).currentTripDirection;
    
    //get stop list
    NSArray* stops = [self.managedObjectContext stopsForRoute:route direction:direction];
    
    //get departure section
    if (indexPath.row < [stops count]) {
        //get the stop
        Stop* stop = [stops objectAtIndex:indexPath.row];
        
        static NSString *CellIdentifier = @"Cell";
        StopCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //add departure
        [cell._libArret setText:stop.name];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //get the current route and direction
    Route* route = ((LinesNavigationController*)self.navigationController).currentTripRoute;
    NSString* direction = ((LinesNavigationController*)self.navigationController).currentTripDirection;
    
    //get the current stop
    NSArray* stops = [self.managedObjectContext stopsForRoute:route direction:direction];
    Stop* stop = [stops objectAtIndex:indexPath.row];
    
    // update it the current trip
    ((LinesNavigationController*)self.navigationController).currentTripStop = stop;
    
    // activate save button
    [self._saveButton setEnabled:YES];
}

@end
