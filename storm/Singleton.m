//
//  Singleton.m
//  storm
//
//  Created by Zack Pajka on 8/16/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "Singleton.h"

@implementation Singleton
@synthesize userId;
@synthesize stormId;
@synthesize serverUrl;
@synthesize gcmSenderId;


#pragma mark - singleton method

+ (Singleton*)sharedInstance
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;

    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}



@end