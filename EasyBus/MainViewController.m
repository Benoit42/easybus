//
//  MainViewController.m
//  EasyBus
//
//  Created by Benoit on 14/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import "MainViewController.h"
#import "FavoritesNavigationController.h"
#import "DeparturesViewController.h"

@implementation MainViewController

@synthesize _refreshDate, _dvc;

#pragma mark - Saturation mémoire
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alerte mémoire" message:@"Dans MainViewController" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
}

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDeparturesNotification:)
                                                 name:@"departuresUpdated"
                                               object:nil];
}

#pragma mark - Initialisation
- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateDeparturesNotification:(NSNotification *)notification
{
    //Refresh de la date
    static NSDateFormatter *timeIntervalFormatter;
    if (!timeIntervalFormatter) {
        timeIntervalFormatter = [[NSDateFormatter alloc] init];
        timeIntervalFormatter.timeStyle = NSDateFormatterFullStyle;
        timeIntervalFormatter.dateFormat = @"HH:mm";
    }
    NSString* maj = [timeIntervalFormatter stringFromDate:[NSDate date]];
    [_refreshDate setText:[[NSString alloc] initWithFormat:@"mis à jour à %@", maj]];
}

#pragma mark - Segues
- (IBAction)unwindFromAlternate:(UIStoryboardSegue *)segue {
    
}

@end
