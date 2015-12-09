//
//  Storm.m
//  storm
//
//  Created by Zack Pajka on 12/8/15.
//  Copyright © 2015 Swerve. All rights reserved.
//

#import "Storm.h"

@implementation Storm

@synthesize CoinsArray;
@synthesize Recipient;
@synthesize SenderId;
@synthesize Message;

-(id) init:(Friend *)toUser withSender:(NSString *)fromUser
{
    self = [super init];
    self.CoinsArray = [[NSMutableArray alloc] init];
    self.Recipient = toUser;
    self.SenderId = fromUser;
    self.Message = @"default message";
    return self;
}

-(void) addCoinToStorm:(Coin *)coin
{
    [self.CoinsArray addObject:coin];
}

@end
