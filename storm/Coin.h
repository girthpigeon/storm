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

@property (nonatomic) double Value;
@property (strong, retain) Friend *Recipient;
@property (strong, retain) Friend *SenderId;

-(id) initWithValue:(double)value ToUser:(Friend *)pal FromUser:(Friend *)sender;

@end
