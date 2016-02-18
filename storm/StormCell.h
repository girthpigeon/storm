//
//  StormCell.h
//  storm
//
//  Created by Zack Pajka on 2/16/16.
//  Copyright © 2016 Swerve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StormCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *m_stormMessageLabel;
@property (nonatomic, weak) IBOutlet UIImageView *m_thumbnailImageView;
@property (nonatomic, weak) IBOutlet UILabel *m_fromUser;
@property (nonatomic, weak) IBOutlet UILabel *m_totalAmount;

@end
