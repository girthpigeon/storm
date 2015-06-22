//
//  MakeItRainViewController.h
//  storm
//
//  Created by Zack Pajka on 6/16/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MakeItRainViewController : UIViewController <UIScrollViewDelegate>

@property(nonatomic, retain) IBOutlet UIImageView *m_currentCoinImageView;
@property (nonatomic, retain) IBOutlet UIImageView *m_nextCoinImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *m_coinChoosingScrollView;

@end
