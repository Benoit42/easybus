//
//  DeparturesViewController.m
//  EasyBus
//
//  Created by Benoit on 11/11/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "DeparturesViewController.h"

@implementation DeparturesViewController

objection_requires(@"groupManager")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Initialisation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Pré-conditions
    NSAssert(self.groupManager != nil, @"groupManager should not be nil");
}

#pragma mark - affichage
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //update header
    NSArray* groups = [self.groupManager groups];
    if (self.page < [groups count]) {
        Group* group = [groups objectAtIndex:self.page];
        [self.direction setText:[NSString stringWithFormat:@"vers %@", group.terminus]];
    }
}

@end
