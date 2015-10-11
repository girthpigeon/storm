//
//  FriendCell.h
//  storm
//
//  Created by Zack Pajka on 10/10/15.
//  Copyright © 2015 Swerve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;

@end
