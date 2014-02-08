//
//  FeedInfoViewController.m
//  EasyBus
//
//  Created by Benoit on 16/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import "FeedInfoViewController.h"
#import "NSManagedObjectContext+Network.h"

@implementation FeedInfoViewController
objection_requires(@"managedObjectContext", @"staticDataLoader")

#pragma mark - IoC
- (void)awakeFromNib {
    [[JSObjection defaultInjector] injectDependencies:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    //Pré-conditions
    NSParameterAssert(self.managedObjectContext != nil);
    NSParameterAssert(self.staticDataLoader != nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Get feed info
    FeedInfo* feedInfo = [self.managedObjectContext feedInfo];
    self.versionLabel.text = feedInfo.version;

    //Manage download
    self.downloadButton.hidden = YES;
    self.progressBar.hidden = YES;
    [self.staticDataLoader checkUpdate:[NSDate date]
        withSuccessBlock:^(BOOL updateNeeded, NSString* version) {
            if (updateNeeded) {
                self.updateLabel.text = @"Une mise à jour est disponible";
                self.updatedVersionLabel.text = version;
                self.downloadButton.hidden = NO;
            }
            else {
                self.updateLabel.text = @"Données à jour";
            }
        }
        andFailureBlock:^(NSError *error) {
            self.updateLabel.text = @"Erreur lors de la vérification des données";
    }];
}

#pragma mark - Refresh Keolis data
- (IBAction)downloadAction:(id)sender {
    NSOperation* op = [NSBlockOperation blockOperationWithBlock:^{
        [self.staticDataLoader loadDataFromWebWithSuccessBlock:^{
            //Get feed info
            FeedInfo* feedInfo = [self.managedObjectContext feedInfo];
            self.versionLabel.text = feedInfo.version;

            //Manage download
            self.updateLabel.text = @"Mise à jour des données effectuée";
            self.updatedVersionLabel.text = nil;
            self.downloadButton.hidden = YES;
            self.progressBar.hidden = YES;
        }
        andFailureBlock:^(NSError *error) {
            self.updateLabel.text = @"Erreur lors du chargement des données";
        }];
    }];
    
    [op start];    
}

@end
