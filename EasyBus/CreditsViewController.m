//
//  CreditsWebViewController.m
//  EasyBus
//
//  Created by Benoit on 11/11/2013.
//  Copyright (c) 2013 Benoit. All rights reserved.
//

#import "CreditsViewController.h"

@implementation CreditsViewController

- (IBAction)facebookAction:(id)sender {
    NSURL* facebookUrl = [NSURL URLWithString: @"fb://profile?id=486394074813801"];
    if ([[UIApplication sharedApplication] canOpenURL:facebookUrl]) {
        [[UIApplication sharedApplication] openURL:facebookUrl];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.facebook.com/easybusrennes"]];
    }
}

- (IBAction)keolisAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://data.keolis-rennes.com/fr/accueil.html"]];
}

- (IBAction)afnetworkingAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://github.com/AFNetworking/AFNetworking"]];
}

- (IBAction)chcsvparserAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://github.com/davedelong/CHCSVParser"]];
}

- (IBAction)objectionAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://github.com/atomicobject/objection"]];
}

- (IBAction)swreavealviewcontrollerAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://github.com/John-Lluch/SWRevealViewController"]];
}

- (IBAction)ziparchiveAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://github.com/mattconnolly/ZipArchive"]];
}

- (IBAction)iconAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://fr.vector.me/browse/151491/bus_clip_art"]];
}

@end
