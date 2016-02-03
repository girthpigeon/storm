//
//  RetrieveCoinsViewController.h
//  storm
//
//  Created by Zack Pajka on 1/12/16.
//  Copyright © 2016 Swerve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RetrieveCoinsViewController : UIViewController <UIGestureRecognizerDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) NSMutableData *m_responseData;

// coin arrays
@property (strong, retain) NSMutableArray *m_coinsArray;
@property (strong, retain) NSMutableArray *m_coinImageViewsArray;
@property (strong, retain) NSMutableArray *m_coinLocationsArray;
@property (strong, retain) NSMutableArray *m_currentlyAnimatingCoinsArray;
@property int m_currentCoinIndex;

@property (strong, retain) UIImageView* m_currentlyDraggedCoinView;

@property (strong, retain) NSMutableDictionary *m_animatingCloudsMap;

// cloudhub
@property (strong, retain) UIImageView *m_cloudHub;
@property (strong, retain) UIView *m_beneathCloud;
@property (strong, retain) UIImageView *m_sunBackButton;
@property (strong, retain) UIImageView *m_recipientImage;

// wallet
@property (strong, retain) UIImageView *m_walletFrontView;
@property (strong, retain) UIImageView *m_walletBackView;
@property CGPoint m_walletFrontViewLocation;
@property CGPoint m_walletBackViewLocation;

// vertical swipe stuff
@property CGPoint m_startPosition;
enum Direction {NONE, TOP};
@property enum Direction m_verticalSwipeDirection;

@property float width;
@property float height;

@end
