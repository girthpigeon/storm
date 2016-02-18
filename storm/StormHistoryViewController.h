//
//  StormHistoryViewController.h
//  storm
//
//  Created by Zack Pajka on 2/16/16.
//  Copyright © 2016 Swerve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StormHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, retain) NSMutableArray *m_stormsArray;
@property (strong, retain) UITableView *m_stormHistoryTable;

@property float width;
@property float height;

@end
