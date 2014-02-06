//
//  Test.m
//  EasyBus
//
//  Created by Benoit on 28/10/12.
//  Copyright (c) 2012 Benoit. All rights reserved.
//

#import <Objection/Objection.h>
#import <XCTest/XCTest.h>
#import "IoCModule.h"
#import "IoCModuleTest.h"
#import "TerminusJsonReader.h"

@interface TerminusJsonReaderTest : XCTestCase

@property(nonatomic) TerminusJsonReader* terminusJsonReader;

@end

@implementation TerminusJsonReaderTest
objection_requires(@"terminusJsonReader")

- (void)setUp
{
    [super setUp];
    
    //IoC
    JSObjectionModule* iocModule = [[IoCModule alloc] init];
    JSObjectionModule* iocModuleTest = [[IoCModuleTest alloc] init];
    JSObjectionInjector *injector = [JSObjection createInjectorWithModules:iocModule, iocModuleTest, nil];
    [JSObjection setDefaultInjector:injector];
    
    //Inject dependencies
    [[JSObjection defaultInjector] injectDependencies:self];
    
    //Load data
    NSURL* tripsUrl = [[NSBundle mainBundle] URLForResource:@"terminus" withExtension:@"json"];
    [self.terminusJsonReader loadData:tripsUrl];
}

- (void)tearDown
{
    [super tearDown];
}

//Vérification des libellés des terminus
- (void)testCheckTerminusLabels {
    XCTAssertEqualObjects(@"Rennes République", self.terminusJsonReader.terminus[@"0064"][@"0"], @"Wrong terminus label");
    XCTAssertEqualObjects(@"Acigné", self.terminusJsonReader.terminus[@"0064"][@"1"], @"Wrong terminus label");
    XCTAssertEqualObjects(@"Rennes République", self.terminusJsonReader.terminus[@"0164"][@"0"], @"Wrong terminus label");
    XCTAssertEqualObjects(@"Acigné", self.terminusJsonReader.terminus[@"0164"][@"1"], @"Wrong terminus label");
    XCTAssertEqualObjects(@"Rennes Lycée Assomption", self.terminusJsonReader.terminus[@"0200"][@"0"], @"Wrong terminus label");
    XCTAssertEqualObjects(@"Acigné", self.terminusJsonReader.terminus[@"0200"][@"1"], @"Wrong terminus label");
}

@end
