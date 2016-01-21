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
    KeychainItemWrapper *userKey = [[KeychainItemWrapper alloc] initWithIdentifier:@"userId" accessGroup:nil];
    KeychainItemWrapper *passKey = [[KeychainItemWrapper alloc] initWithIdentifier:@"passKey" accessGroup:nil];

    NSString *userId = [userKey objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [passKey objectForKey:(__bridge id)(kSecAttrAccount)];
    
    if (userId == nil || [userId isEqualToString:@""])
    {
        Singleton* appData = [Singleton sharedInstance];
        appData.userId = @"user";
        appData.password = @"user";
    }
    else
    {
        appData.userId = userId;
        appData.password = password;
        appData.userId = @"user";
        appData.password = @"user";
    }

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
    NSString *postString = [NSString stringWithFormat:@"fromUser=%@&toUser=%@&message=%@", appData.userId, toUser, message];
    //NSString* urlString = [NSString stringWithFormat:@"%@api/storms?%@", appData.serverUrl, postString];
    NSString* urlString = [NSString stringWithFormat:@"%@api/storms?", appData.serverUrl];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [request setValue:[NSString stringWithFormat:@"%@", appData.token] forHTTPHeaderField:@"X-Auth-Token"];
    
    NSURLResponse* response;
    NSError* error = nil;
    NSString *stormId = @"";
    
    [request setValue:[NSString 
                   stringWithFormat:@"%lu", (unsigned long)[postString length]]
                    forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString
                      dataUsingEncoding:NSUTF8StringEncoding]];

    //Capturing server response
    NSData* result = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
         
    if (response != nil)
    {
        NSDictionary *allJSON = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:nil];
        stormId = [allJSON objectForKey:@"id"];
    }
    
    return stormId;
}

+ (void) sendCoin:(int)coinValue withStorm:(Storm*)storm
{
    /*fromUsername": "string",
  "id": 0,
  "isCollected": true,
  "storm": {
    "fromUser": "string",
    "id": 0,
    "isActive": true,
    "message": "string",
    "toUser": "string"
  },
  "toUsername": "string",
  "value": 0*/
    
    // send a coin with coinValue to server
    Singleton* appData = [Singleton sharedInstance];
    
    NSString *urlString = [NSString stringWithFormat:@"%@api/coins?", appData.serverUrl];
    NSString *fullUrl = [NSString stringWithFormat:@"%@fromUsername=%@&fromUser=%@&message=%@&toUser=%@&toUsername=%@&value=%d&id=%@", urlString, appData.userId, appData.userId, storm.Message, storm.Recipient, storm.Recipient, coinValue, storm.StormId];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         if (response != nil)
         {
             NSDictionary *allJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             NSDictionary *coin = [allJSON objectForKey:@"Coin"];
             NSDictionary *storm = [allJSON objectForKey:@"Storm"];
             
             NSString *coinId = [coin objectForKey:@"id"];
             NSLog(@"%@", coinId);
         }
     }];
}

@end
