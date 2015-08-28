//
//  SendCoinsViewController.m
//  storm
//
//  Created by Zack Pajka on 8/24/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "SendCoinsViewController.h"
#import "Singleton.h"

@implementation SendCoinsViewController

NSMutableArray *m_coinsArray;
NSMutableArray *m_coinValuesArray;
NSMutableArray *m_coinViewsArray;
NSMutableArray *m_coinImageViewsArray;

int m_currentCoinIndex;

CGFloat m_lastContentOffset;

enum ScrollDirection
{
    Left,
    Right
};

enum ScrollDirection m_scrollDirection;
bool m_finishedPaginate;

// vertical swipe stuff
CGPoint m_startPosition;
enum Direction {NONE, TOP};
enum Direction m_verticalSwipeDirection;

#define COIN_WIDTH 100
#define COIN_HEIGHT 100

float width;
float height;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    width = screenRect.size.width;
    height = screenRect.size.height;
    
    //width = self.view.bounds.size.width;
    //height = self.view.bounds.size.height;
    
    [self createCoinsArray];
    [self setupCoinViews];
    
    UIPanGestureRecognizer* verticalPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWasRecognized:)];
    [self.view addGestureRecognizer:verticalPan];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.horizontalScrollView = nil;
}

- (void)createCoinsArray
{
    m_coinsArray =[[NSMutableArray alloc]init];
    
    [m_coinsArray  addObject:[UIImage imageNamed:@"Coin1.png"]];
    [m_coinsArray  addObject:[UIImage imageNamed:@"Couin5.png"]];
    [m_coinsArray  addObject:[UIImage imageNamed:@"Coin10.png"]];
    [m_coinsArray  addObject:[UIImage imageNamed:@"Coin25.png"]];
    
    m_coinValuesArray =[[NSMutableArray alloc]init];
    
    [m_coinValuesArray  addObject:[NSNumber numberWithInt:1]];
    [m_coinValuesArray  addObject:[NSNumber numberWithInt:5]];
    [m_coinValuesArray  addObject:[NSNumber numberWithInt:10]];
    [m_coinValuesArray  addObject:[NSNumber numberWithInt:25]];
}

- (void)setupCoinViews
{
    self.horizontalScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,((height/5) * 4), width, height)];
    [self resetCoinViews];
    
    self.horizontalScrollView.contentSize = CGSizeMake(self.view.frame.size.width * m_coinsArray.count, self.view.frame.size.height);
    [self.horizontalScrollView setPagingEnabled:TRUE];
    [self.horizontalScrollView setDelegate:self];
    [self.horizontalScrollView setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:self.horizontalScrollView];
}

- (void)resetCoinViews
{
    m_coinViewsArray = [[NSMutableArray alloc] init];
    m_coinImageViewsArray = [[NSMutableArray alloc] init];
    for (int i=0; i < m_coinsArray.count; i++)
    {
        CGRect frame;
        frame.origin.x = (width/2) * i;
        frame.origin.y = 0;
        frame.size.width = width/2;
        frame.size.height = height;
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        subview.backgroundColor = [UIColor clearColor];
        
        float coinXPosition = (width/2) - COIN_WIDTH/2;
        frame = CGRectMake(coinXPosition, height/2, COIN_WIDTH, COIN_HEIGHT);
        
        UIImageView *coinImageView = [[UIImageView alloc] initWithFrame:frame];

        UIImage *coin = [m_coinsArray objectAtIndex:i];
        
        coinImageView.image = coin;
        [m_coinImageViewsArray addObject:coinImageView];
        
        [subview addSubview:coinImageView];
        [self.view addSubview:subview];
        
        [m_coinViewsArray addObject:subview];
    }
    m_currentCoinIndex = 0;
    m_lastContentOffset = 0.0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (m_lastContentOffset > scrollView.contentOffset.x)
        m_scrollDirection = Right;
    else if (m_lastContentOffset < scrollView.contentOffset.x)
        m_scrollDirection = Left;
    
    m_lastContentOffset = scrollView.contentOffset.x;
    
    if (m_finishedPaginate)
    {
        m_finishedPaginate = false;
        
        if (m_scrollDirection == Left)
        {
            for (int i = 0; i < m_coinViewsArray.count; i++)
            {
                UIView *currentView = [m_coinViewsArray objectAtIndex:i];
                
                // animate old view out
                [UIView animateWithDuration:.3
                                 animations:^{
                                     currentView.frame = CGRectMake(currentView.frame.origin.x - width/2, currentView.frame.origin.y, currentView.frame.size.width, currentView.frame.size.height);
                                 }];
            }
            m_currentCoinIndex++;
        }
        else if (m_scrollDirection == Right)
        {
            for (int i = m_coinViewsArray.count - 1; i >= 0; i--)
            {
                UIView *currentView = [m_coinViewsArray objectAtIndex:i];
                
                // animate old view out
                [UIView animateWithDuration:.3
                                 animations:^{
                                     currentView.frame = CGRectMake(currentView.frame.origin.x + width/2, currentView.frame.origin.y, currentView.frame.size.width, currentView.frame.size.height);
                                 }];
            }
            m_currentCoinIndex--;
        }

    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{

    m_finishedPaginate = true;
}

- (void)panWasRecognized:(UIPanGestureRecognizer *)panner {
    
    CGFloat distance = 0;
    CGPoint stopLocation;
    if (panner.state == UIGestureRecognizerStateBegan)
    {
        m_startPosition = [panner locationInView:self.view];
    }
    else
    {
        stopLocation = [panner locationInView:self.view];
        CGFloat dx = stopLocation.x - m_startPosition.x;
        CGFloat dy = stopLocation.y - m_startPosition.y;
        distance = sqrt(dx*dx + dy*dy);
    }
    
    UIImageView *currentCoin = [m_coinImageViewsArray objectAtIndex:m_currentCoinIndex];
    
    CGPoint offset = [panner translationInView:currentCoin.superview];
    CGPoint center = currentCoin.center;
    currentCoin.center = CGPointMake(center.x + offset.x, center.y + offset.y);
    
    // Reset translation to zero so on the next `panWasRecognized:` message, the
    // translation will just be the additional movement of the touch since now.
    [panner setTranslation:CGPointZero inView:currentCoin.superview];
    
    NSLog(@"stopLocation.y: %f", stopLocation.y);
    NSLog(@"height / 3: %f", height / 3);
    if (stopLocation.y < height / 3)
    {
       m_verticalSwipeDirection = TOP;
    }
    
    if(panner.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocity = [panner velocityInView:self.view];
        
        NSLog(@"velocity: %f", velocity);
        if(m_verticalSwipeDirection == TOP)
        {
            float coinXPosition = (width/2) - COIN_WIDTH/2;
            CGRect frame = CGRectMake(coinXPosition, height/2, COIN_WIDTH, COIN_HEIGHT);

            UIImageView *coinImageView = [[UIImageView alloc] initWithFrame:frame];
            UIImage *newImage = [m_coinsArray objectAtIndex:m_currentCoinIndex];
            coinImageView.image = newImage;
            [m_coinImageViewsArray insertObject:coinImageView atIndex:m_currentCoinIndex + 1];
            
            UIView *currentView = [m_coinViewsArray objectAtIndex:m_currentCoinIndex];
            [currentView addSubview:coinImageView];
            
            
            
            [UIImageView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationCurveLinear
                             animations:^{
                                 currentCoin.center = CGPointMake(currentCoin.center.x, -100);
                             }
                             completion:^(BOOL finished)
                            {
                                 
                                 [currentCoin removeFromSuperview];
                                 [m_coinImageViewsArray removeObjectAtIndex:m_currentCoinIndex];
                                 [self madeItRain:currentCoin];
                             }];
        }
    }
}

-(void)madeItRain:(UIImageView*)draggedImage
{
    //int coinValue = [[m_coinValuesArray objectAtIndex:m_currentCoinIndex] integerValue];
    //[self sendCoin:coinValue];
    [self resetImage];
}

-(void)sendCoin:(int) coinValue
{
    // send a coin with coinValue to server
    Singleton* appData = [Singleton sharedInstance];
    
    NSString *defaultMessage = @"Ryan sucks eggs";
    NSString *defaultToUser = @"558746ccd1e77f4a2a9a0d92";
    
    NSString *urlString = [NSString stringWithFormat:@"%@Coin/sendCoin?", appData.serverUrl];
    //http://localhost:1337/Coin/sendCoin?from=558746ccd1e77f4a2a9a0d91&to=558746ccd1e77f4a2a9a0d91&value=100&message=Ten Dimes is Chill&stormKey=558746ccd1e77f4a2a9a0d92
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"from=%@&to=%@&value=%d&message=%@&stormKey=%@", appData.userId, defaultToUser, coinValue, defaultMessage, appData.stormId];
    
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

-(void)resetImage
{
    //UIImageView *currentView = [m_coinViewsArray objectAtIndex:m_currentCoinIndex];
    //self.m_currentCoinImageView.frame = CGRectMake(width, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
    //self.m_nextCoinImageView.frame = CGRectMake((width- COIN_WIDTH)/2, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);

}

@end
