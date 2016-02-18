//
//  Storm.h
//  storm
//
//  Created by Zack Pajka on 12/8/15.
//  Copyright © 2015 Swerve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Friend.h"
#import "Coin.h"

@interface Storm : NSObject

@property (strong, retain) NSMutableArray *CoinsArray;
@property (strong, retain) Friend *Recipient;
@property (strong, retain) NSString *SenderId;
@property (strong, retain) NSString *Message;
@property (strong, retain) NSString *StormId;

// special items only certain storms have
@property (strong, retain) NSString *SenderFullName;
@property (strong, retain) UIImage *SenderProf;
@property (strong, retain) NSString *MoneyRedeemed;

- (id) init:(Friend *)toUser withSender:(NSString *)fromUser;
- (id) initHistoryStorm:(NSString *)fromFullName withStormId:(NSString *)stormId withMessage:(NSString *)message withProf:(NSString *)profPic;
- (void) addCoinToStorm:(Coin *)coin;
- (void) setMoneyRedeemed:(NSString *)moneyRedeemed withMoneySent:(NSString *) moneySent;


@end
