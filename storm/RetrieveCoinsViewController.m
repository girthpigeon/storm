//
//  RetrieveCoinsViewController.m
//  storm
//
//  Created by Zack Pajka on 1/12/16.
//  Copyright © 2016 Swerve. All rights reserved.
//

#import "RetrieveCoinsViewController.h"
#import "Singleton.h"
#import "Friend.h"
#import "Utils.h"
#import "FriendCell.h"
#import "Storm.h"
#import "Coin.h"

@interface RetrieveCoinsViewController ()

@end

@implementation RetrieveCoinsViewController

@synthesize width;
@synthesize height;

#define COIN_WIDTH 100
#define COIN_HEIGHT 100

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    width = screenRect.size.width;
    height = screenRect.size.height;
    
    [self setupHubCloud];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) retrieveNextCoins
{
    // retrieve next n coins (sorted by value amt and expiration)
    self.m_coinsArray = [[NSMutableArray alloc] init]; // full of Coin objects
}

- (void) setupCoinViews
{
    self.m_coinImageViewsArray = [[NSMutableArray alloc] init]; // visual representation of all coins in batch
    
}

- (void) setupHubCloud
{
    UIImageView *cloudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainCloud.png"]];
    CGRect frame;
    
    // bounding box for coins
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = width;
    frame.size.height = (height / 4);
    
    UIView* behindCloud = [[UIView alloc] initWithFrame:frame];
    [behindCloud setBackgroundColor:self.view.backgroundColor];
    
    [self.view addSubview:behindCloud];
    
    frame.origin.x = width / 20;
    frame.origin.y = height / 25;
    frame.size.width = (width / 20) * 18;
    frame.size.height = (height / 4);
    
    cloudView.frame = frame;
    
    [cloudView setUserInteractionEnabled:YES];
    
    // sun back button
    self.m_backButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sun.png"]];
    CGRect sunFrame;
    sunFrame.origin.x = 0 - 30;
    sunFrame.origin.y = 0 - 30;
    sunFrame.size.width = width / 3;
    sunFrame.size.height = width / 3;
    
    self.m_backButton.frame = sunFrame;
    
    UITapGestureRecognizer *sunTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backButtonTouched:)];
    [sunTouch setDelegate:self];
    
    [self.m_backButton setUserInteractionEnabled:YES];
    [self.view addSubview:self.m_backButton];
    [self.view addSubview:cloudView];
    
    // recipient circle
    self.m_recipientImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProfilePictureHolder.png"]];
    
    frame.origin.x = width /2 + width / 5;
    frame.origin.y = (height / 20) * 3;
    frame.size.width = 75;
    frame.size.height = 75;
    self.m_recipientImage.frame = frame;
    
    UITapGestureRecognizer *friendPickerTouched = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickFriendsTouched:)];
    [friendPickerTouched setDelegate:self];
    
    [self.m_recipientImage setUserInteractionEnabled:YES];
    
    [self.view addSubview:self.m_recipientImage];
    
    [self.m_backButton addGestureRecognizer:sunTouch];
    [self.m_recipientImage addGestureRecognizer:friendPickerTouched];
}


@end
