//
//  VenmoLoginURLProtocol.m
//  storm
//
//  Created by Zack Pajka on 7/13/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "VenmoLoginURLProtocol.h"
#import "KeychainItemWrapper.h"
#import "Singleton.h"

@implementation VenmoLoginURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    static NSUInteger requestCount = 0;
    NSLog(@"Request #%lu: URL = %@", (unsigned long)requestCount++, request);
    
    NSString *requestPath = [[request URL] absoluteString];
    if ([NSURLProtocol propertyForKey:requestPath inRequest:request])
    {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    NSString *requestPath = [[newRequest URL] absoluteString];
    [NSURLProtocol setProperty:@YES forKey:requestPath inRequest:newRequest];
    
    self.m_connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void)stopLoading
{
    [self.m_connection cancel];
    self.m_connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.m_responseData = [[NSMutableData alloc] init];
    
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.m_responseData appendData:data];
    
    [self.client URLProtocol:self didLoadData:data];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response)
    {
        NSMutableURLRequest *redirect = [request mutableCopy];
        NSString *requestPath = [[request URL] absoluteString];
        [NSURLProtocol removePropertyForKey:requestPath inRequest:redirect];
        //[RequestHelper addWebViewHeadersToRequest:redirect];
        
        [self.client URLProtocol:self wasRedirectedToRequest:redirect redirectResponse:response];
        
        return redirect;
    }
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
    
    NSString *responseString = [[NSString alloc] initWithData:self.m_responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    if (responseString != nil)
    {
        NSError *e = nil;
        NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error: &e];
        
        if ([JSON count] == 3)
         {
             NSString *userId = [JSON objectForKey:@"username"];
             NSString *password = [JSON objectForKey:@"password"];
             NSDictionary *token = [JSON objectForKey:@"token"];
             
             KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"username" accessGroup:nil];
             [keychain setObject:userId forKey:(__bridge id)(kSecAttrAccount)];
             
             KeychainItemWrapper *keychain2 = [[KeychainItemWrapper alloc] initWithIdentifier:@"password" accessGroup:nil];
             [keychain2 setObject:password forKey:(__bridge id)(kSecAttrAccount)];
             
             NSString *tokenId = [token objectForKey:@"token"];
             
             Singleton* appData = [Singleton sharedInstance];
             appData.userId = userId;
             appData.stormId = password;
             appData.token = tokenId;
          
             [[NSNotificationCenter defaultCenter] postNotificationName:@"NSURLConnectionDidFinish" object:nil];
         }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
}

@end
