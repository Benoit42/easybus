//
//  LocationManagerTest.m
//  EasyBus
//
//  Created by Benoit on 24/12/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ZipArchive.h"

@interface ZipArchiveTest : SenTestCase

@end

@implementation ZipArchiveTest : SenTestCase

//Test de l'ajout
- (void)testUnzip
{
    //Initialisations
    NSFileManager* fm  = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    //Nettoyage préalable
    NSString *unzippedFilePath = [documentsDirectory stringByAppendingPathComponent:@"test.rtf"];
    [fm removeItemAtPath:unzippedFilePath error:nil];
    
    //Dézippage
    NSString *zipFilePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"zip"];
    STAssertTrue([fm fileExistsAtPath:zipFilePath], @"Zip file does not exist");
    ZipArchive* za = [[ZipArchive alloc] init];
    
    if(! [za UnzipOpenFile:zipFilePath] ) {
        STFail(@"Unable to open zip file");
    }
    if( [za UnzipFileTo:documentsDirectory overWrite:YES] == NO ) {
        STFail(@"Unable to unzip file");
    }

    //Unzip succeeded
    [za UnzipCloseFile];
    
    //Vérification
    STAssertTrue([fm fileExistsAtPath:unzippedFilePath], @"Unzipped file does not exist");
}

@end
