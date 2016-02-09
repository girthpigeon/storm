//
//  AppDelegate.h
//  storm
//
//  Created by Zack Pajka on 6/7/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/CloudMessaging.h>

@interface StormAppDelegate : UIResponder <UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, readonly, strong) NSString *registrationKey;
@property(nonatomic, readonly, strong) NSString *messageKey;
@property(nonatomic, readonly, strong) NSString *gcmSenderID;
@property(nonatomic, readonly, strong) NSDictionary *registrationOptions;


@end

