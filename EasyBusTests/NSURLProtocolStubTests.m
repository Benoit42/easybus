//
//  NSURLProtocolStubTests.m
//  EPGWithAvalaibleContent
//
//  Created by Yannick LE SAOUT on 08/07/13.
//  Copyright (c) 2013 Orange. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>
#import "AsyncTestCase.h"
#import "NSURLProtocolStub.h"

@interface NSURLProtocolStubTests : AsyncTestCase

@end

@implementation NSURLProtocolStubTests

// Bind an url and verify that the object returned in the success block is the one bound
- (void)testBoundUrlToFile {
    //Configure url stubbing
    NSString *url = @"http://example.com/testBoundUrlRequest";
    [NSURLProtocol registerClass:[NSURLProtocolStub class]];
    [NSURLProtocolStub bindUrl:url toResource:@"testBoundUrlRequest.json"];

    //Launch request
    AFJsonRequestWrapper *jsonRequestWrapper = [[AFJsonRequestWrapper alloc] init];
    [self runTestWithBlock:^{
        
        [jsonRequestWrapper fetchJsonAtUrl:url
            withSuccessBlock:^(NSDictionary *Json) {
                if (! [[Json objectForKey:@"boundUrl"] isEqualToString:@"success"]) {
                    STFail(@"The return dictionnary is not the one configured");
                }
                [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
            }
            withErrorBlock:^(NSError *error) {
                STFail([error description]);
                [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
            }
        ];
    }];
}

// Bind an partial url and verify that the object returned in the success block is the one bound
- (void)testBoundPartialUrlToFile {
    //Configure url stubbing
    NSString *binding = @"http://example.com/testBoundUrlRequest";
    [NSURLProtocol registerClass:[NSURLProtocolStub class]];
    [NSURLProtocolStub bindUrl:binding toResource:@"testBoundUrlRequest.json"];
    
    //Launch request
    NSString *url = @"http://example.com/testBoundUrlRequest/xxx";
    AFJsonRequestWrapper *jsonRequestWrapper = [[AFJsonRequestWrapper alloc] init];
    [self runTestWithBlock:^{
        
        [jsonRequestWrapper fetchJsonAtUrl:url
                          withSuccessBlock:^(NSDictionary *Json) {
                              if (! [[Json objectForKey:@"boundUrl"] isEqualToString:@"success"]) {
                                  STFail(@"The return dictionnary is not the one configured");
                              }
                              [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
                          }
                            withErrorBlock:^(NSError *error) {
                                STFail([error description]);
                                [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
                            }
         ];
    }];
}

// Bind an partial url and verify that the object returned in the success block is the one bound
- (void)testBoundUrlAndPartialUrlToFile {
    //Configure url stubbing
    NSString *completeBinding = @"http://example.com/testBoundUrlRequest/xx";
    [NSURLProtocol registerClass:[NSURLProtocolStub class]];
    [NSURLProtocolStub bindUrl:completeBinding toResource:@"testBoundUrlRequest2.json"];
    
    NSString *partialBinding = @"http://example.com/testBoundUrlRequest";
    [NSURLProtocol registerClass:[NSURLProtocolStub class]];
    [NSURLProtocolStub bindUrl:partialBinding toResource:@"testBoundUrlRequest.json"];

    //Launch request
    AFJsonRequestWrapper *jsonRequestWrapper = [[AFJsonRequestWrapper alloc] init];
    [self runTestWithBlock:^{
        
        [jsonRequestWrapper fetchJsonAtUrl:completeBinding
                          withSuccessBlock:^(NSDictionary *Json) {
                              if (! [[Json objectForKey:@"boundUrl"] isEqualToString:@"success2"]) {
                                  STFail(@"The return dictionnary is not the one configured");
                              }
                              [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
                          }
                            withErrorBlock:^(NSError *error) {
                                STFail([error description]);
                                [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
                            }
         ];
    }];
}

// Bind an urlto a file that does not exist and verify that the erro returned in the failur block is 404
- (void)testBoundUrlToInexitingFile {
    //Configure url stubbing
    NSString *url = @"http://example.com/testNotFoundRequest";
    [NSURLProtocol registerClass:[NSURLProtocolStub class]];
    [NSURLProtocolStub bindUrl:url toResource:@"doesnotexists.json"];
    
    //Launch request
    AFJsonRequestWrapper *jsonRequestWrapper = [[AFJsonRequestWrapper alloc] init];
    [self runTestWithBlock:^{
        
        [jsonRequestWrapper fetchJsonAtUrl:url
                          withSuccessBlock:^(NSDictionary *Json) {
                              STFail(@"Shouldn't have executed the success block");
                              [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
                          }
                            withErrorBlock:^(NSError *error) {
                                [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
                            }
         ];
    }];
}

//Configure an url with statusCode diffrent from 200
- (void)testConfigureUrlWith503StatusCode {
    //Configure url stubbing
    NSString *url = @"http://example.com/testConfigureUrlWith503StatusCode";
    [NSURLProtocol registerClass:[NSURLProtocolStub class]];
    [NSURLProtocolStub configureUrl:url withStatusCode:[NSNumber numberWithLong:503]];
    
    //Launch request
    AFJsonRequestWrapper *jsonRequestWrapper = [[AFJsonRequestWrapper alloc] init];
    [self runTestWithBlock:^{
        
        [jsonRequestWrapper fetchJsonAtUrl:url
            withSuccessBlock:^(NSDictionary *Json) {
                if (! [[Json objectForKey:@"boundUrl"] isEqualToString:@"success"])
                    STFail(@"Request should have been in error");
                [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
            }
            withErrorBlock:^(NSError *error) {
                if ([error.localizedDescription rangeOfString:@"503"].location == NSNotFound) {
                    STFail(@"status code not properly returned");
                }
                [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
            }
         ];
    }];
}

// Configure an url with headers
- (void)testConfigureUrlWithHeaders {
    //Configure url stubbing
    NSString *url = @"http://example.com/testConfigureUrlWithHeaders";
    [NSURLProtocol registerClass:[NSURLProtocolStub class]];
    [NSURLProtocolStub configureUrl:url withHeaders:@{@"Content-Type": @"text/xml"}];
    
    //Launch request
    AFJsonRequestWrapper *jsonRequestWrapper = [[AFJsonRequestWrapper alloc] init];
    [self runTestWithBlock:^{
        
        [jsonRequestWrapper fetchJsonAtUrl:url
            withSuccessBlock:^(NSDictionary *Json) {
                STFail(@"Shouldn't have executed the success block");
                [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
            }
            withErrorBlock:^(NSError *error) {
                if ([error.localizedDescription rangeOfString:@"xpected content type"].location == NSNotFound) {
                    STFail(@"Should have return an error on the expected content type");
                }
                [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
        }];
    }];
}

// Bind an url configure it with a status code of 404 and  headers
- (void)testBindUrlAndConfigureWithStatusCodeAndHeaders {
    //Configure url stubbing
    NSString *url = @"http://example.com/testBindUrlAndConfigureWithStatusCodeAndHeaders";
    [NSURLProtocol registerClass:[NSURLProtocolStub class]];
    [NSURLProtocolStub bindUrl:url toResource:@"testBoundUrlRequest.json"];
    [NSURLProtocolStub configureUrl:url withStatusCode:[NSNumber numberWithLong:404]];
    [NSURLProtocolStub configureUrl:url withHeaders:@{@"Content-Type": @"text/json"}];

    //Launch request
    AFJsonRequestWrapper *jsonRequestWrapper = [[AFJsonRequestWrapper alloc] init];
    [self runTestWithBlock:^{
        
        [jsonRequestWrapper fetchJsonAtUrl:url withSuccessBlock:^(NSDictionary *Json) {
            STFail(@"Request should have been in error");
            [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
        } withErrorBlock:^(NSError *error) {
            if ([error.localizedDescription rangeOfString:@"404"].location == NSNotFound) {
                STFail(@"status code not properly returned");
            }
            
            if ([error.localizedRecoverySuggestion rangeOfString:@"boundUrl"].location == NSNotFound) {
                STFail(@"Json file not correctly bound");
            }

            [self performSelectorOnMainThread:@selector(blockTestCompletedWithBlock:) withObject:nil waitUntilDone:NO];
        }];
    }];
}

@end
