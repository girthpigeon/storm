//
//  Friend.h
//  storm
//
//  Created by Zack Pajka on 10/3/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Friend : NSObject

@property (strong, retain) NSString* FirstName;
@property (strong, retain) NSString* LastName;
@property (strong, retain) UIImage* ProfPic;
@property (strong, retain) NSString* UserId;

@end
