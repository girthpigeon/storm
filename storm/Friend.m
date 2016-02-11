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
@synthesize FullName;
@synthesize Username;
@synthesize ProfPic;

-(id)initWithFirst:(NSString *)first Last:(NSString *)last Username:(NSString *)username ProfUrl:(NSString *)profUrl
{
    self = [super init];
    self.FirstName = first;
    self.LastName = last;
    self.Username = username;
    self.ProfPic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profUrl]]];
    self.FullName = [NSString stringWithFormat:@"%@ %@", first, last];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:FirstName forKey:@"FirstName"];
    [coder encodeObject:LastName    forKey:@"LastName"];
    [coder encodeObject:FullName forKey:@"FullName"];
    [coder encodeObject:Username   forKey:@"Username"];
    [coder encodeObject:ProfPic   forKey:@"ProfPic"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.FirstName = [coder decodeObjectForKey:@"FirstName"];
    self.LastName    = [coder decodeObjectForKey:@"LastName"];
    self.FullName = [coder decodeObjectForKey:@"FullName"];
    self.Username    = [coder decodeObjectForKey:@"Username"];
    self.ProfPic = [coder decodeObjectForKey:@"ProfPic"];

    return self;
}
    
@end
