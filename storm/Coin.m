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

-(id) initWithValue:(double)value ToUser:(Friend *)receiver FromUser:(Friend *)sender
{
    self = [super init];
    self.Value = value;
    self.Recipient = receiver;
    self.SenderId = sender;
    return self;
}

@end
