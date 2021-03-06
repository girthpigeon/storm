//
//  DBManager.h
//  storm
//
//  Created by Zack Pajka on 1/19/16.
//  Copyright © 2016 Swerve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Storm.h"

@interface DBManager : NSObject

@property (nonatomic, retain) NSData* m_responseData;

+ (void) authenticate;

+ (void)createStorm:(NSString*)toUser withMessage:(NSString*)message withCoinValue:(double)coinValue toRecipient:(Friend*)recipient;
+ (void) sendCoin:(double)coinValue withStorm:(Storm*)storm;

@end
