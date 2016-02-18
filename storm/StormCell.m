//
//  StormCell.m
//  storm
//
//  Created by Zack Pajka on 2/16/16.
//  Copyright © 2016 Swerve. All rights reserved.
//

#import "StormCell.h"

@implementation StormCell

@synthesize m_stormMessageLabel;
@synthesize m_fromUser;
@synthesize m_thumbnailImageView;
@synthesize m_totalAmount;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
