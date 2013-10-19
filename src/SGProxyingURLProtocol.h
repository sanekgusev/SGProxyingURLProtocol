//
//  SGProxyingURLProtocol.h
//  SGProxyingURLProtocol
//
//  Created by Alexander Gusev on 8/25/13.
//  Copyright (c) 2013 sanekgusev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGProxyingURLProtocol : NSURLProtocol

- (NSURLRequest *)requestWillStartLoading:(NSURLRequest *)request;
- (void)requestDidFinishLoading:(NSURLRequest *)request;
- (void)request:(NSURLRequest *)request
didFailWithError:(NSError *)error;
- (void)requestWasCancelled:(NSURLRequest *)request;
- (NSURLRequest *)request:(NSURLRequest *)request
receivedRedirectResponse:(NSURLResponse *)redirectResponse
redirectRequest:(NSURLRequest *)redirectRequest;

@end
