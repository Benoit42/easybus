//
//  FlipsideViewController.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "DirectionViewController.h"
#import "LinesNavigationController.h"
#import "StopsViewController.h"
#import "DirectionCell.h"
#import "Route+RouteWithAdditions.h"

@implementation DirectionViewController
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get departure section
    if (indexPath.row < 2) {
        static NSString *CellIdentifier = @"Cell";
        DirectionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //get the favorite fromnav controler
        Route* route = ((LinesNavigationController*)self.navigationController).currentFavoriteRoute;

        //add departure
        NSString* libelle = [route terminusForDirection:[NSString stringWithFormat:@"%i", indexPath.row]];
        [cell._libDirection setText:libelle];
        return cell;
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //get the favorite fromnav controler
    ((LinesNavigationController*)self.navigationController).currentFavoriteDirection = [NSString stringWithFormat:@"%i", indexPath.row];
}

@end
