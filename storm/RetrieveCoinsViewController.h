//
//  RetrieveCoinsViewController.h
//  storm
//
//  Created by Zack Pajka on 1/12/16.
//  Copyright © 2016 Swerve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RetrieveCoinsViewController : UIViewController <UIGestureRecognizerDelegate>

// coin arrays
@property (strong, retain) NSMutableArray *m_coinsArray;
@property (strong, retain) NSMutableArray *m_coinImageViewsArray;
@property (strong, retain) NSMutableArray *m_coinLocationsArray;
@property (strong, retain) NSMutableArray *m_currentlyAnimatingCoinsArray;
@property int m_currentCoinIndex;

@property (strong, retain) UIImageView* m_currentlyDraggedCoinView;

@property (strong, retain) NSMutableDictionary *m_animatingCloudsMap;

@property (strong, retain) NSMutableData *m_responseData;

// cloudhub
@property (strong, retain) UIImageView *m_cloudHub;
@property (strong, retain) UIView *m_beneathCloud;
@property (strong, retain) UIImageView *m_backButton;
@property (strong, retain) UIImageView *m_recipientImage;

// vertical swipe stuff
@property CGPoint m_startPosition;
enum Direction {NONE, TOP};
@property enum Direction m_verticalSwipeDirection;

@property float width;
@property float height;

@end
