//
//  Friend.h
//  storm
//
//  Created by Zack Pajka on 10/3/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Friend : NSObject <NSCoding>

@property (strong, retain) NSString* FirstName;
@property (strong, retain) NSString* LastName;
@property (strong, retain) NSString* FullName;
@property (strong, retain) UIImage* ProfPic;
@property (strong, retain) NSString* Username;

-(id)initWithFirst:(NSString *)first Last:(NSString *)last Username:(NSString *)username ProfUrl:(NSString *)profUrl;

@end
