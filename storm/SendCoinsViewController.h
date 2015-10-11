//
//  SendCoinsViewController.h
//  storm
//
//  Created by Zack Pajka on 8/24/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendCoinsViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, NSURLConnectionDelegate>

@property (strong, retain) IBOutlet UIScrollView *horizontalScrollView;
@property (weak, nonatomic) IBOutlet UITableView *m_friendsList;

@end
