//
//  Friend.m
//  storm
//
//  Created by Zack Pajka on 10/3/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "Friend.h"

@implementation Friend

@synthesize FirstName;
@synthesize LastName;
@synthesize Username;
@synthesize ProfPic;

-(id)initWithFirst:(NSString *)first Last:(NSString *)last Username:(NSString *)username ProfUrl:(NSString *)profUrl
{
    self = [super init];
    self.FirstName = first;
    self.LastName = last;
    self.Username = username;
    self.ProfPic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profUrl]]];
    
    return self;
}
    
@end
