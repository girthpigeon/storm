//
//  SendCoinsViewController.m
//  storm
//
//  Created by Zack Pajka on 8/24/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "SendCoinsViewController.h"

@implementation SendCoinsViewController

NSMutableArray *m_coinsArray;
NSMutableArray *m_coinValuesArray;
NSMutableArray *m_coinViewsArray;

int m_currentCoinIndex;

CGFloat m_lastContentOffset;

enum ScrollDirection
{
    Left,
    Right
};

enum ScrollDirection m_scrollDirection;
bool m_finishedPaginate;

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
        //[self.view addSubview:subview];
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

@end
