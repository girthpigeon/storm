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
@synthesize StormId;
@synthesize SenderFullName;
@synthesize SenderProf;
@synthesize MoneyRedeemed;

- (id) init:(Friend *)toUser withSender:(NSString *)fromUser
{
    self = [super init];
    self.CoinsArray = [[NSMutableArray alloc] init];
    self.Recipient = toUser;
    self.SenderId = fromUser;
    self.Message = @"default message";
    return self;
}

// only to be used for storm history view
-(id) initHistoryStorm:(NSString *)fromFullName withStormId:(NSString *)stormId withMessage:(NSString *)message withProf:(NSString *)profPic
{
    self = [super init];
    self.SenderFullName = fromFullName;
    self.StormId = stormId;
    self.Message = message;
    self.SenderProf = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profPic]]];
    return self;
}

-(void) addCoinToStorm:(Coin *)coin
{
    [self.CoinsArray addObject:coin];
}

- (void) setCollectionStatus:(NSString *)moneyCollected withMoneySent:(NSString *)moneySent
{
    self.MoneyRedeemed = [NSString stringWithFormat:@"$%@/%@", moneyCollected, moneySent];
}

@end
