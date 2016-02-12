//
//  SendCoinsViewController.h
//  storm
//
//  Created by Zack Pajka on 8/24/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendCoinsViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, NSURLConnectionDelegate, UITextFieldDelegate>

@property (strong, retain) IBOutlet UIScrollView *horizontalScrollView;
@property (weak, nonatomic) IBOutlet UITableView *m_friendsList;

@property (strong, retain) NSString *firstUsername;

@property (strong, nonatomic) NSUserDefaults *defaults;

@property (strong, retain) NSMutableDictionary *m_animatingCloudsMap;

@property (strong, retain) UIButton *m_backButton;

#define FRIENDS_KEY @"friends"

@end
