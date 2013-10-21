//
//  NSURLProtocolStub.h
//  EPGWithAvalaibleContent
//
//  Created by Yannick LE SAOUT on 05/07/13.
//  Copyright (c) 2013 Orange. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLProtocolStub : NSURLProtocol

+ (void)initialize;

+ (void)bindUrl:(NSString *)url toResource:(NSString *)resource;

+ (void)configureUrl:(NSString *)url withStatusCode:(NSNumber *)statusCode;

+ (void)configureUrl:(NSString *)url withHeaders:(NSDictionary *)headers;

+ (void)resetBindings;

@end
