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

-(id) init:(Friend *)toUser withSender:(NSString *)fromUser;
-(void) addCoinToStorm:(Coin *)coin;


@end
