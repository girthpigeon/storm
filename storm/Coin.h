//
//  Coin.h
//  storm
//
//  Created by Zack Pajka on 12/8/15.
//  Copyright © 2015 Swerve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Friend.h"

@interface Coin : NSObject

@property double Value;
@property (strong, retain) NSString *Recipient;
@property (strong, retain) NSString *SenderId;
@property (strong, retain) NSString *CoinId;

-(id) initWithValue:(double)value ToUser:(NSString *)pal FromUser:(NSString *)sender;

@end
