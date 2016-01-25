//
//  DBManager.m
//  storm
//
//  Created by Zack Pajka on 1/19/16.
//  Copyright © 2016 Swerve. All rights reserved.
//

#import "Singleton.h"
#import "DBManager.h"
#import "KeychainItemWrapper.h"

@implementation DBManager
 
 @synthesize m_responseData;

+ (void) authenticate
{
    Singleton* appData = [Singleton sharedInstance];
    KeychainItemWrapper *userKey = [[KeychainItemWrapper alloc] initWithIdentifier:@"username" accessGroup:nil];
    KeychainItemWrapper *passKey = [[KeychainItemWrapper alloc] initWithIdentifier:@"password" accessGroup:nil];

    NSString *userId = [userKey objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [passKey objectForKey:(__bridge id)(kSecAttrAccount)];
    
    appData.userId = userId;
    appData.password = password;

    // create post call
    NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@", appData.userId, appData.password];
    NSString* urlString = [NSString stringWithFormat:@"%@api/authenticate?%@", appData.serverUrl, postString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]] forHTTPHeaderField:@"Content-length"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
        
        if (response != nil)
        {
            NSDictionary *allJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            //NSDictionary *result = [allJSON objectForKey:@"result"];
            
            NSString *expires = [allJSON objectForKey:@"expires"];
            NSString *token = [allJSON objectForKey:@"token"];
            NSLog(@"%@", token);
            appData.token = token;
        }
    }];
}

+ (NSString*) createStorm:(NSString*)toUser withMessage:(NSString*)message
{
    Singleton* appData = [Singleton sharedInstance];
    
    // create post call
    NSString *postString = [NSString stringWithFormat:@"{"
    @"    \"fromUser\": \"%@\","
    @"    \"toUser\": \"%@\","
    @"    \"message\": \"%@\" }" ,
    appData.userId, toUser, message];

    NSString* urlString = [NSString stringWithFormat:@"%@api/storms?", appData.serverUrl];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSURLResponse* response;
    NSError* error = nil;
    NSString *stormId = @"";
    
    [request setValue:appData.token forHTTPHeaderField:@"X-Auth-Token"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

    //Capturing server response
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
         
    if (response != nil)
    {
        NSDictionary *allJSON = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:nil];
        stormId = [allJSON objectForKey:@"id"];
    }
    
    return stormId;
}

+ (void) sendCoin:(double)coinValue withStorm:(Storm*)storm
{
    // send a coin with coinValue to server
    Singleton* appData = [Singleton sharedInstance];
    
    NSString *urlString = [NSString stringWithFormat:@"%@api/coins?", appData.serverUrl];
    NSString *postString = [NSString stringWithFormat:@"{"
                            @"    \"fromUsername\": \"%@\","
                            @" \"storm\": {"
                                @"    \"fromUser\": \"%@\","
                                @"    \"message\": \"%@\","
                                @"    \"toUser\": \"%@\","
                                @"    \"id\": \"%@\" }, "
                            @"    \"toUsername\": \"%@\","
                            @"    \"value\": \"%f\" }",
                            appData.userId, appData.userId, storm.Message, storm.Recipient.Username, storm.StormId, storm.Recipient.Username, coinValue];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:appData.token forHTTPHeaderField:@"X-Auth-Token"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (response != nil)
         {
             NSDictionary *allJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             NSDictionary *coinId = [allJSON objectForKey:@"id"];
             
             NSLog(@"%@", coinId); // have some toasty ui flash when a coin successfully sends.
             // send push notification from server side
         }
     }];
}

@end
