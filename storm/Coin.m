//
//  Coin.m
//  storm
//
//  Created by Zack Pajka on 12/8/15.
//  Copyright © 2015 Swerve. All rights reserved.
//

#import "Coin.h"

@implementation Coin

@synthesize Value;
@synthesize Recipient;
@synthesize SenderId;

-(id) init:(double)value toUser:(Friend *)toUser fromUser:(NSString *)sender
{
    self = [super init];
    self.Value = value;
    self.Recipient = toUser;
    self.SenderId = sender;
    return self;
}

@end
