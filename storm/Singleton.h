//
//  Singleton.h
//  storm
//
//  Created by Zack Pajka on 8/16/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Storm.h"

@interface Singleton : NSObject <NSURLConnectionDelegate>

+ (Singleton*) sharedInstance;

@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSString* stormId;
@property (nonatomic, retain) NSString* serverUrl;
@property (nonatomic, retain) NSString* clientSecret;
@property (nonatomic, retain) NSString* serverSecret;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* gcmSenderId;
@property (nonatomic, retain) Storm* currentStorm;

@end
