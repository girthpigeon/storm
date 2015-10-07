//
//  Utils.m
//  storm
//
//  Created by Zack Pajka on 10/5/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "Utils.h"

@implementation Utils

- (UIImageView *)circlize:(UIImage *)image withFrame:(CGRect)frame
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = frame;
    
    imageView.layer.cornerRadius = imageView.frame.size.height /2;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 0;
    
    return imageView;
}

@end
