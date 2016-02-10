//
//  AppDelegate.m
//  storm
//
//  Created by Zack Pajka on 6/7/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "StormAppDelegate.h"
#import "VenmoLoginURLProtocol.h"
#import "HomeScreenViewController.h"
#import "Singleton.h"
#import "KeychainItemWrapper.h"
#import "DBManager.h"


@interface StormAppDelegate ()

@property(nonatomic, strong) void (^registrationHandler)
(NSString *registrationToken, NSError *error);
@property(nonatomic, assign) BOOL connectedToGCM;
@property(nonatomic, strong) NSString* registrationToken;
@property(nonatomic, assign) BOOL subscribedToTopic;

@end

NSString *const SubscriptionTopic = @"/topics/global";

@implementation StormAppDelegate

NSString *APP_SECRET = @"AscAHGZmtjXKSndTC9kxJXXgcrdmpMeT";
NSString *APP_ID = @"2858 ";
NSString *APP_NAME = @"Twister";
NSString *serverUrl = @"http://storm-of-coins.herokuapp.com/";

NSString *gcmSenderId = @"784590731314";

NSString *_registrationKey;
NSString *_messageKey;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //[Venmo startWithAppId:APP_ID secret:APP_SECRET name:APP_NAME];
    Singleton* appData = [Singleton sharedInstance];
    appData.serverUrl = serverUrl;
    
    KeychainItemWrapper *userKey = [[KeychainItemWrapper alloc] initWithIdentifier:@"username" accessGroup:nil];
    NSString *userId = [userKey objectForKey:(__bridge id)(kSecAttrAccount)];
    //userId = @"don't do login shit";// comment this out
    if (userId == nil || [userId isEqualToString:@""])
    {
        [NSURLProtocol registerClass:[VenmoLoginURLProtocol class]];
    }
    
    [DBManager authenticate];
    
    HomeScreenViewController *homeScreenVC = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
    UINavigationController *navigationController=[[UINavigationController alloc] initWithRootViewController:homeScreenVC];
    
    _registrationKey = @"onRegistrationCompleted";
    _messageKey = @"pushReceived";
    // Configure the Google context: parses the GoogleService-Info.plist, and initializes
    // the services that have entries in the file
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    _gcmSenderID = gcmSenderId;
    appData.gcmSenderId = gcmSenderId;
    
    // Register for remote notifications
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeAlert);
        [application registerForRemoteNotificationTypes:allNotificationTypes];
    } else {
        
        // iOS 8 or later
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeAlert);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    GCMConfig *gcmConfig = [GCMConfig defaultConfig];
    gcmConfig.receiverDelegate = self;
    [[GCMService sharedInstance] startWithConfig:gcmConfig];
    
    __weak typeof(self) weakSelf = self;
    
    // Handler for registration token request
    _registrationHandler = ^(NSString *registrationToken, NSError *error){
        if (registrationToken != nil) {
            weakSelf.registrationToken = registrationToken;
            NSLog(@"Registration Token: %@", registrationToken);
            //[weakSelf subscribeToTopic];
            NSDictionary *userInfo = @{@"registrationToken":registrationToken};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
            
            // register with server
            NSString *postString = [NSString stringWithFormat:@"username=%@&registrationToken=%@", appData.userId, weakSelf.registrationToken];
            NSString* urlString = [NSString stringWithFormat:@"%@api/notification/registerDevice?%@", appData.serverUrl, postString];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:urlString]];
            
            [request setHTTPMethod:@"POST"];
            
            [request setValue:appData.token forHTTPHeaderField:@"X-Auth-Token"];
            [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]] forHTTPHeaderField:@"Content-length"];
            
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 
                 if (response != nil)
                 {
                     NSDictionary *allJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                 }
             }];
            
        } else {
            NSLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
            NSDictionary *userInfo = @{@"error":error.localizedDescription};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
        }
    };
    
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
    
    // Start the GGLInstanceID shared instance with the that config and request a registration
    // token to enable reception of notifications
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
    _registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                             kGGLInstanceIDAPNSServerTypeSandboxOption:@NO};
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
    }

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Registration for remote notification failed with error: %@", error.localizedDescription);

    NSDictionary *userInfo = @{@"error" :error.localizedDescription};
    [[NSNotificationCenter defaultCenter] postNotificationName:_registrationKey
                                                        object:nil
                                                      userInfo:userInfo];
}


- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)data {
    
    NSLog(@"Notification received: %@", data);

    [[GCMService sharedInstance] appDidReceiveMessage:data];
    // Handle the received message
    
    [[NSNotificationCenter defaultCenter] postNotificationName:_messageKey
                                                        object:nil
                                                      userInfo:data];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userData
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    NSLog(@"Notification received: %@", userData);

    [[GCMService sharedInstance] appDidReceiveMessage:userData];

    // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
    [[NSNotificationCenter defaultCenter] postNotificationName:_messageKey
                                                        object:nil
                                                      userInfo:userData];
    
    NSString *value = [userData objectForKey:@"value"];
    NSString *fromUser = [userData objectForKey:@"fromUser"];
    
    if (application.applicationState == UIApplicationStateActive ) {
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userData;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [NSString stringWithFormat:@"%@ sent you $0.%@", fromUser, value];
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
    handler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)onTokenRefresh {
    // A rotation of the registration tokens is happening, so the app needs to request a new token.
    NSLog(@"The GCM registration token needs to be changed.");
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
}

// [START upstream_callbacks]
- (void)willSendDataMessageWithID:(NSString *)messageID error:(NSError *)error {
    if (error) {
        // Failed to send the message.
    } else {
        // Will send message, you can save the messageID to track the message
    }
}

- (void)didSendDataMessageWithID:(NSString *)messageID {
    // Did successfully send message identified by messageID
}
// [END upstream_callbacks]

- (void)didDeleteMessagesOnServer {
    // Some messages sent to this device were deleted on the GCM server before reception, likely
    // because the TTL expired. The client should notify the app server of this, so that the app
    // server can resend those messages.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
   // if ([[Venmo sharedInstance] handleOpenURL:url]) {
        return YES;
   // }
    // You can add your app-specific url handling code here if needed
    return NO;
}

@end
