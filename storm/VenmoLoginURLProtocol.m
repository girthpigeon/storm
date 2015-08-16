//
//  VenmoLoginURLProtocol.m
//  storm
//
//  Created by Zack Pajka on 7/13/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "VenmoLoginURLProtocol.h"

@implementation VenmoLoginURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    static NSUInteger requestCount = 0;
    NSLog(@"Request #%u: URL = %@", requestCount++, request);
    
    if ([NSURLProtocol propertyForKey:@"VenmoURLProtocolHandledKey" inRequest:request]) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"VenmoURLProtocolHandledKey" inRequest:newRequest];
    
    self.m_connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void)stopLoading {
    [self.m_connection cancel];
    self.m_connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.m_responseData = [[NSMutableData alloc] init];
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.m_responseData appendData:data];
    
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    
    NSString *responseString = [[NSString alloc] initWithData:self.m_responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    //NSError *e = nil;
    //NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    //NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error: &e];
    
    /*if ([JSON count] > 0)
    {
        NSString *stormKey = [JSON objectForKey:@"stormKey"];
        NSString *userId = [JSON objectForKey:@"userId"];
    }*/

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

@end
