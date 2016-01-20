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

- (void) sendCoin:(int)coinValue toUser:(NSString*)toUser withMessage:(NSString*)message
{
    //curl -X POST --header "Content-Type: application/json" --header "Accept: application/json" --header "X-Auth-Token: admin:1452661056346:f7624723064d43f68c442e212a940f76" -d "{
    //\"message\": \"its ya boi Zack\"
    //}" "http://localhost:8080/api/storms"
    // [mutableRequest addValue:@"Hless" forHTTPHeaderField:@"X-user-nick"];
    
    // send a coin with coinValue to server
    Singleton* appData = [Singleton sharedInstance];
    
    NSString *defaultMessage = message;
    NSString *defaultToUser = toUser;
    
    NSString *urlString = [NSString stringWithFormat:@"%@Coin/sendCoin?", appData.serverUrl];
    NSString *fullUrl = [NSString stringWithFormat:@"%@from=%@&to=%@&value=%d&message=%@", urlString, appData.userId, defaultToUser, coinValue, defaultMessage];
    
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
             //NSDictionary *result = [allJSON objectForKey:@"result"];
             
             NSString *expires = [allJSON objectForKey:@"expires"];
             NSString *token = [allJSON objectForKey:@"token"];
             NSLog(@"%@", token);
             appData.token = token;
         }
     }];
}

/*
// This method is used to process the data after connection has made successfully.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:m_responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    if (responseString != nil)
    {
        NSError *e = nil;
        NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error: &e];
        
        if ([JSON count] == 2)
        {
            NSString *username = [JSON objectForKey:@"username"];
            NSString *firstName = [JSON objectForKey:@"first_name"];
            NSString *lastName = [JSON objectForKey:@"last_name"];
            NSString *profUrl = [JSON objectForKey:@"profile_picture_url"];
            Friend *pal = [[Friend alloc] initWithFirst:firstName Last:lastName Username:username ProfUrl:profUrl];
            [m_friendsArray addObject:pal];
        }
    }
}*/

@end
