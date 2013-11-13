//
//  DeparturesViewController.m
//  EasyBus
//
//  Created by Benoit on 11/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "DeparturesViewController.h"
#import "DeparturesTableViewController.h"

@implementation DeparturesViewController
objection_register(DeparturesViewController);

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Pré-conditions
    NSParameterAssert(self.group != nil);
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //update header
    [self.direction setText:[NSString stringWithFormat:@"vers %@", self.group.terminus]];
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"tableView"]) {
        ((DeparturesTableViewController*)segue.destinationViewController).group = self.group;
    }
}
@end
