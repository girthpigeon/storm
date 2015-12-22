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

@interface StormAppDelegate ()

@end

@implementation StormAppDelegate

NSString *APP_SECRET = @"AscAHGZmtjXKSndTC9kxJXXgcrdmpMeT";
NSString *APP_ID = @"2858 ";
NSString *APP_NAME = @"Twister";
NSString *serverUrl = @"https://coin-storm.herokuapp.com/";

NSString *serverSecret = @"johnson@1-pajka@1-riebling@2-skobov@3";
NSString *clientSecret = @"skobov@1-riebling@1-pajka@2-johnson@3";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //[Venmo startWithAppId:APP_ID secret:APP_SECRET name:APP_NAME];
    Singleton* appData = [Singleton sharedInstance];
    appData.serverUrl = serverUrl;
    appData.serverSecret = serverSecret;
    appData.clientSecret = clientSecret;
    
    KeychainItemWrapper *userKey = [[KeychainItemWrapper alloc] initWithIdentifier:@"userId" accessGroup:nil];
    NSString *userId = [userKey objectForKey:(__bridge id)(kSecAttrAccount)];
    //userId = @"don't do login shit";// comment this out
    if (userId == nil || [userId isEqualToString:@""])
    {
        //[NSURLProtocol registerClass:[VenmoLoginURLProtocol class]]; // uncomment this when verification works again
        appData.userId = @"6";
        appData.stormId = @"2";
    }
    
    HomeScreenViewController *homeScreenVC = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreenViewController" bundle:nil];
    UINavigationController *navigationController=[[UINavigationController alloc] initWithRootViewController:homeScreenVC];
    //self.window.rootViewController = navigationController;
    //[self.window makeKeyAndVisible];
    
    return YES;
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
