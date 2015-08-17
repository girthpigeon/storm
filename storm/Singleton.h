//
//  Singleton.h
//  storm
//
//  Created by Zack Pajka on 8/16/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Singleton : NSObject

+ (Singleton*)sharedInstance;

@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSString* stormId;
@property (nonatomic, retain) NSString* serverUrl;

@end
