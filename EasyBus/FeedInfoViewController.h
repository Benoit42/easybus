//
//  FeedInfoViewController.h
//  EasyBus
//
//  Created by Benoit on 16/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataManager.h"
#import "GtfsDownloadManager.h"

@interface FeedInfoViewController : UIViewController

@property (strong, nonatomic) StaticDataManager* staticDataManager;
@property (strong, nonatomic) GtfsDownloadManager* gtfsDownloadManager;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;
@property (strong, nonatomic) IBOutlet UIView *progressBar;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

- (IBAction)downloadAction:(id)sender;

@end
