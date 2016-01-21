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
;
#define COIN_WIDTH 100
#define COIN_HEIGHT 100

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    width = screenRect.size.width;
    height = screenRect.size.height;
    
    [self setupHubCloud];
    [self retrieveNextCoins];
    
    UIPanGestureRecognizer* verticalPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWasRecognized:)];
    [self.view addGestureRecognizer:verticalPan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) retrieveNextCoins
{
    // retrieve next n coins (sorted by value amt and expiration)
    if (self.m_coinsArray == nil)
    {
        self.m_coinsArray = [[NSMutableArray alloc] init]; // full of Coin objects
    }
    Singleton* appData = [Singleton sharedInstance];
    for (int i=0; i < 15; i++)
    {
        int lowerBound = 0;
        int upperBound = 3;
        int rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
        Friend *pal = [[Friend alloc] initWithFirst:@"zack" Last:@"pajka" Username:@"zackpa" ProfUrl:@"whatever.com"];
        
        double value = 0.0;
        if (rndValue == 0)
        {
            value = .01;
        }
        else if (rndValue == 1)
        {
            value = .05;
        }
        else if (rndValue == 2)
        {
            value = .1;
        }
        else if (rndValue == 3)
        {
            value = .25;
        }
        
        Coin* coin = [[Coin alloc] initWithValue:value ToUser:pal FromUser:pal];
        [self.m_coinsArray addObject:coin];
    }
    
    [self setupCoinViews];
}

- (void) setupCoinViews
{
    if (self.m_coinImageViewsArray == nil)
    {
        self.m_coinImageViewsArray = [[NSMutableArray alloc] init]; // visual representation of all coins in batch
    }
    
    for (int i=0; i < self.m_coinsArray.count; i++)
    {
        Coin* coin = [self.m_coinsArray objectAtIndex:i];
        NSString* imageName = @"";
        if (coin.Value == .01)
        {
            imageName = @"Coin1.png";
        }
        else if (coin.Value == .05)
        {
            imageName = @"Couin5.png";
        }
        else if (coin.Value == .10)
        {
            imageName = @"Coin10.png";
        }
        else if (coin.Value == .25)
        {
            imageName = @"Coin25.png";
        }
        UIImageView* coinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        [self.m_coinImageViewsArray addObject:coinView];
        [self randomizeCoinPlacements:coinView];
        
        [self.view insertSubview:coinView belowSubview:self.m_cloudHub];
    }
}

- (void) randomizeCoinPlacements:(UIImageView *)imageView
{
    CGRect frame;
    
    int lowerBound = 25;
    int upperBound = width - 100;
    int rndX = lowerBound + arc4random() % (upperBound - lowerBound);
    
    lowerBound = height / 25 + (height / 4) - 75; // y origin of cloud + height of cloud - half of coin height
    upperBound = height / 25 + (height / 4) - 25;
    int rndY = lowerBound + arc4random() % (upperBound - lowerBound);
    
    frame.origin.x = rndX;
    frame.origin.y = rndY;
    frame.size.width = COIN_WIDTH;
    frame.size.height = COIN_HEIGHT;
    
    imageView.frame = frame;
}

- (void) setupHubCloud
{
    self.m_cloudHub = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainCloud.png"]];
    CGRect frame;
    
    // bounding box for hub
    frame.origin.x = width / 20;
    frame.origin.y = height / 25;
    frame.size.width = (width / 20) * 18;
    frame.size.height = (height / 4);
    
    self.m_cloudHub.frame = frame;
    
    // bounding box for coin drag initiation
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = width;
    frame.size.height = 2 * (height / 5);
    
    UITapGestureRecognizer *coinGrab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(grabBestCoin:)];
    [coinGrab setDelegate:self];
    
    self.m_beneathCloud = [[UIView alloc] initWithFrame:frame];
    [self.m_beneathCloud setBackgroundColor:[UIColor clearColor]];
    [self.m_beneathCloud addGestureRecognizer:coinGrab];
    
    
    
    [self.m_cloudHub setUserInteractionEnabled:YES];
    
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
    [self.view addSubview:self.m_cloudHub];
    [self.view addSubview:self.m_beneathCloud];
    
    // recipient circle
    self.m_recipientImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProfilePictureHolder.png"]];
    
    frame.origin.x = width /2 + width / 5;
    frame.origin.y = (height / 20) * 3;
    frame.size.width = 75;
    frame.size.height = 75;
    self.m_recipientImage.frame = frame;
    
    UITapGestureRecognizer *friendPickerTouched = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(senderHubTouched:)];
    [friendPickerTouched setDelegate:self];
    
    [self.m_recipientImage setUserInteractionEnabled:YES];
    
    [self.view addSubview:self.m_recipientImage];
    
    [self.m_backButton addGestureRecognizer:sunTouch];
    [self.m_recipientImage addGestureRecognizer:friendPickerTouched];
}

-(void)backButtonTouched:(UITapGestureRecognizer *)tap
{
    
}

-(void)senderHubTouched:(UITapGestureRecognizer *)tap
{
    
}

- (void) grabBestCoin:(UITapGestureRecognizer *)tap
{
   

}

-(void)panWasRecognized:(UIPanGestureRecognizer *)panner
{
    
    CGFloat distance = 0;
    CGPoint stopLocation;
    CGFloat dx = 0.0;
    CGFloat dy = 0.0;
    
    if (self.m_coinImageViewsArray.count < 5)
    {
        [self retrieveNextCoins];
    }
    
    UIImageView *currentCoin = [self.m_coinImageViewsArray objectAtIndex:0];
    Coin *coin = [self.m_coinsArray objectAtIndex:0];
    NSLog(@"Coin: %f", coin.Value);
    
    if (panner.state == UIGestureRecognizerStateBegan)
    {
        self.m_startPosition = [panner locationInView:self.view];
        //currentCoin =[m_coinImageViewsArray objectAtIndex:m_currentCoinIndex];
    }
    else
    {
        stopLocation = [panner locationInView:self.view];
        dx = stopLocation.x - self.m_startPosition.x;
        dy = stopLocation.y - self.m_startPosition.y;
        distance = sqrt(dx*dx + dy*dy);
    }
    
    CGPoint offset = [panner translationInView:currentCoin.superview];
    CGPoint center = currentCoin.center;
    currentCoin.center = CGPointMake(center.x + offset.x, center.y + offset.y);
    
    // Reset translation to zero so on the next `panWasRecognized:` message, the
    // translation will just be the additional movement of the touch since now.
    [panner setTranslation:CGPointZero inView:currentCoin.superview];
    
    if(panner.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [panner velocityInView:self.view];
        
        CGFloat projectedX = 0.0;
        CGFloat projectedY = 0.0;
        
        // animation
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        // Move the "cursor" to the start
        [path moveToPoint:currentCoin.center];
        
        if(currentCoin.center.y < height * .40) // successful coin fling, coin flies up
        {
            projectedX = currentCoin.center.x + dx*2;
            projectedY = 0 - COIN_HEIGHT;
        }
        else // unsuccessful fling, coin falls
        {
            projectedX = currentCoin.center.x + dx*2;
            projectedY = height + COIN_HEIGHT;
        }
        
        // set animation endpoint
        CGPoint c2 = CGPointMake(projectedX, projectedY);
        
        CGFloat movePoints = projectedX - currentCoin.center.x;
        CGFloat duration = movePoints / (velocity.x/3);
        
        CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        //pathAnimation.calculationMode = kCAAnimationPaced;
        
        // Draw a curve towards the end, using control points
        [path addCurveToPoint:c2 controlPoint1:c2 controlPoint2:c2];
        
        // Use this path as the animation's path (casted to CGPath)
        pathAnimation.path = path.CGPath;
        
        // The other animations properties
        pathAnimation.fillMode              = kCAFillModeForwards;
        pathAnimation.removedOnCompletion   = NO;
        pathAnimation.duration              = duration;
        pathAnimation.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        // Apply it
        [pathAnimation setDelegate:self];
        [pathAnimation setValue:@"coinFling" forKey:@"tag"];
        [currentCoin.layer addAnimation:pathAnimation forKey:@"coinFling"];
        
        [self coinRetrieved:currentCoin];
        
        // remove flung coin from current array, add to animated array
        [self.m_currentlyAnimatingCoinsArray addObject:currentCoin];
        [self.m_coinImageViewsArray removeObjectAtIndex:0];
    }
}

-(void) coinRetrieved:(UIImageView *)currentCoin
{
    
}


@end