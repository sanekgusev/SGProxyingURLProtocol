//
//  SGProxyingURLProtocol.m
//  SGProxyingURLProtocol
//
//  Created by Alexander Gusev on 8/25/13.
//  Copyright (c) 2013 sanekgusev. All rights reserved.
//

#import "SGProxyingURLProtocol.h"

static NSString * const kModifiedPropertyKey =
    @"com.sanekgusev.SGProxyingURLProtocol.requestModified";

@interface SGProxyingURLProtocol()<NSURLConnectionDataDelegate> {
    NSURLConnection * __weak _connection;
}

@end

@implementation SGProxyingURLProtocol

#pragma mark - Init/dealloc

- (id)initWithRequest:(NSURLRequest *)request
       cachedResponse:(NSCachedURLResponse *)cachedResponse
               client:(id<NSURLProtocolClient>)client {
    if (self = [super initWithRequest:request
                       cachedResponse:cachedResponse
                               client:client]) {
    }
    return self;
}

#pragma mark - NSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    BOOL requestAlreadyProcessed = [[NSURLProtocol propertyForKey:kModifiedPropertyKey
                                                        inRequest:request] boolValue];
    return !requestAlreadyProcessed;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSURLRequest *request = [self requestWillStartLoading:[self request]];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:kModifiedPropertyKey
                     inRequest:mutableRequest];
    _connection = [NSURLConnection connectionWithRequest:mutableRequest
                                                delegate:self];

}

- (void)stopLoading {
    NSURLRequest *request = [_connection currentRequest];
    [_connection cancel];
    [self requestWasCancelled:request];
}

#pragma mark - Public

- (NSURLRequest *)requestWillStartLoading:(NSURLRequest *)request {
    return request;
}

- (void)requestDidFinishLoading:(NSURLRequest *)request {

}

- (void)request:(NSURLRequest *)request
didFailWithError:(NSError *)error {

}

- (void)requestWasCancelled:(NSURLRequest *)request {

}

- (NSURLRequest *)request:(NSURLRequest *)request
receivedRedirectResponse:(NSURLResponse *)redirectResponse
redirectRequest:(NSURLRequest *)redirectRequest {
    return redirectRequest;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[self client] URLProtocol:self didFailWithError:error];
    [self request:[_connection currentRequest] didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response {
    NSURLRequest *redirectRequest = [self request:[_connection currentRequest]
                         receivedRedirectResponse:response
                                  redirectRequest:request];
    
    [[self client] URLProtocol:self
        wasRedirectedToRequest:redirectRequest
              redirectResponse:response];

    return redirectRequest;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self
            didReceiveResponse:response
            cacheStoragePolicy:[[self request] cachePolicy]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
    [self requestDidFinishLoading:[_connection currentRequest]];
}

@end
