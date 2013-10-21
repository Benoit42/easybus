 //
//  NSURLProtocolStub.m
//  EPGWithAvalaibleContent
//
//  Created by Yannick LE SAOUT on 05/07/13.
//  Copyright (c) 2013 Orange. All rights reserved.
//

#import "NSURLProtocolStub.h"

//Default values configuration
#define defaultHeaders @{@"Content-Type": @"application/json; charset=utf-8"}
#define defaultStatusCode 200
#define notFoundStatusCode 404
#define defaultHTTPProtocol @"HTTP/1.1"


// Dictionary of bound Urls
static NSMutableDictionary *_boundUrl = nil;


@implementation NSURLProtocolStub

+ (void)initialize
{
    if (! _boundUrl)
        _boundUrl = [[NSMutableDictionary alloc] init];
}

+ (void)bindUrl:(NSString *)url toResource:(NSString *)resource
{
    NSMutableDictionary *configuredUrl = [_boundUrl objectForKey:url];
    
    if (configuredUrl)
    {
        [configuredUrl setObject:resource forKey:@"resource"];
    }
    else
    {
        configuredUrl = [NSMutableDictionary dictionaryWithObject:resource forKey:@"resource"];
        [_boundUrl setObject:configuredUrl forKey:url];
    }
}

+ (void)configureUrl:(NSString *)url withStatusCode:(NSNumber *)statusCode
{
    NSMutableDictionary *configuredUrl = [_boundUrl objectForKey:url];
    
    if (configuredUrl)
    {
        [configuredUrl setObject:statusCode forKey:@"statusCode"];
    }
    else
    {
        configuredUrl = [NSMutableDictionary dictionaryWithObject:statusCode forKey:@"statusCode"];
        [_boundUrl setObject:configuredUrl forKey:url];
    }
    
}

+ (void)configureUrl:(NSString *)url withHeaders:(NSDictionary *)headers
{
    NSMutableDictionary *configuredUrl = [_boundUrl objectForKey:url];
    
    if (configuredUrl)
    {
        [configuredUrl setObject:headers forKey:@"headers"];
    }
    else
    {
        configuredUrl = [NSMutableDictionary dictionaryWithObject:headers forKey:@"headers"];
        [_boundUrl setObject:configuredUrl forKey:url];
    }
}

+(void)resetBindings{

    [_boundUrl removeAllObjects];
}

#pragma mark - NSProtocolOverides
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    // For now only supporting http GET, and existing binding
    NSDictionary *urlConfig = [self bindingForUrl:request];
    BOOL result = [[[request URL] scheme] isEqualToString:@"http"] && [[request HTTPMethod] isEqualToString:@"GET"] && (urlConfig != nil);
    return result;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSURLRequest *request = [self request];
    id client = [self client];
    NSDictionary *urlConfig = [NSURLProtocolStub bindingForUrl:request];
    NSString *fileLocation = [urlConfig objectForKey:@"resource"];
    NSNumber *statusCode = [urlConfig objectForKey:@"statusCode"];
    NSDictionary *headers = [urlConfig objectForKey:@"headers"];
    
    if (! statusCode)
        statusCode = [NSNumber numberWithLong:defaultStatusCode];
    else
        statusCode = [NSNumber numberWithLong:[statusCode longValue]];
    
    if (!headers)
        headers = defaultHeaders;
    
    //Load the file content
    NSHTTPURLResponse *response = nil;
    NSData* data = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileLocation stringByDeletingPathExtension] ofType:[fileLocation pathExtension]];
    if (filePath == nil) {
        //file not found
        response = [[NSHTTPURLResponse alloc] initWithURL:[request URL]
                                               statusCode:notFoundStatusCode
                                              HTTPVersion:defaultHTTPProtocol
                                             headerFields:headers];
    }
    else {
        data = [NSData dataWithContentsOfFile:filePath];
        
        // Send the canned data
        response = [[NSHTTPURLResponse alloc] initWithURL:[request URL]
                       statusCode:[statusCode intValue]
                       HTTPVersion:defaultHTTPProtocol
                       headerFields:headers];
    }

    [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [client URLProtocol:self didLoadData:data];
    [client URLProtocolDidFinishLoading:self];
    [client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
    
}

#pragma mark - internals
+ (NSDictionary*)bindingForUrl:(NSURLRequest*)request {
    //Récupération de l'url
    NSString* url = [[request URL] absoluteString];
    
    //Tri des clés
    NSArray* sortedBindings = [[_boundUrl allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString* key1, NSString* key2) {
        return [key2 compare:key1];
    }];
    
    //Parcours du dictionnaire en cherchant un binding qui matche l'url (le début de l'url est égal au binding)
    __block NSString* binding;
    [sortedBindings enumerateObjectsUsingBlock:^(NSString* key, NSUInteger idx, BOOL *stop) {
        if ([url hasPrefix:key]) {
            binding = key;
            *stop = YES;
        }
    }];
    
    //Retour
    return [_boundUrl objectForKey:binding];
}

@end
