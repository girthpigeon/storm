//
//  MakeItRainViewController.m
//  storm
//
//  Created by Zack Pajka on 6/16/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "MakeItRainViewController.h"
#import "Singleton.h"

@implementation MakeItRainViewController

NSMutableArray *m_coinsArray;
NSMutableArray *m_coinValuesArray;
int m_currentCoinIndex = 0;
CGPoint _startLocation;
BOOL _directionAssigned = NO;
enum direction {LEFT,RIGHT, TOP};
enum direction _direction;
enum activeImageView {CURRENT,NEXT};
enum activeImageView _activeImage = CURRENT;
BOOL _reassignIncomingImage = YES;

CGFloat width;
CGFloat height;

#define COIN_WIDTH 100
#define COIN_HEIGHT 100

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCoinsArray];
    
    width = self.view.bounds.size.width;
    height = self.view.bounds.size.height;
    
    UIImage *currentImage = [m_coinsArray objectAtIndex:m_currentCoinIndex];
    self.m_currentCoinImageView.frame = CGRectMake(width/2, height/2, COIN_WIDTH, COIN_HEIGHT);
    self.m_currentCoinImageView.image = currentImage;
    
    UIImage *nextImage = [m_coinsArray objectAtIndex:m_currentCoinIndex+1];
    self.m_nextCoinImageView.frame = CGRectMake(width, height/2, COIN_WIDTH, COIN_HEIGHT);
    self.m_nextCoinImageView.image = nextImage;
    
    [self.walletView addSubview:self.m_currentCoinImageView];
    [self.walletView addSubview:self.m_nextCoinImageView];
    
    UIImage *walletBackImage = [UIImage imageNamed:@"WalletHalfBack.png"];
    self.m_walletBackImageView.frame = CGRectMake(0, height/4, width, height);
    self.m_walletBackImageView.image = walletBackImage;
    UIImage *walletFrontImage = [UIImage imageNamed:@"WalletHalfFront.png"];
    self.m_walletFrontImageView.frame = CGRectMake(0, height/5, width, height);
    self.m_walletFrontImageView.image = walletFrontImage;
    
    [self.walletView addSubview:self.m_walletBackImageView];
    [self.walletView addSubview:self.m_walletFrontImageView];
    
    UIPanGestureRecognizer* horizontalPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(horizontalSwipeRecognized:)];
    [self.walletView addGestureRecognizer:horizontalPan];
    
    UIPanGestureRecognizer* verticalPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWasRecognized:)];
    [self.view addGestureRecognizer:verticalPan];
    
    [self resetImages];
}

-(void)viewDidLayoutSubviews
{
    
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

- (void)panWasRecognized:(UIPanGestureRecognizer *)panner {
    
    CGFloat distance = 0;
    CGPoint stopLocation;
    if (panner.state == UIGestureRecognizerStateBegan)
    {
        _directionAssigned = NO;
        _startLocation = [panner locationInView:self.view];
    }
    else
    {
        stopLocation = [panner locationInView:self.view];
        CGFloat dx = stopLocation.x - _startLocation.x;
        CGFloat dy = stopLocation.y - _startLocation.y;
        distance = sqrt(dx*dx + dy*dy);
    }
    
    UIImageView *draggedImage;
    if (_activeImage == CURRENT)
    {
        draggedImage = self.m_currentCoinImageView;
    }
    else
    {
        draggedImage = self.m_nextCoinImageView;
    }
    
    CGPoint offset = [panner translationInView:draggedImage.superview];
    CGPoint center = draggedImage.center;
    draggedImage.center = CGPointMake(center.x + offset.x, center.y + offset.y);
    
    // Reset translation to zero so on the next `panWasRecognized:` message, the
    // translation will just be the additional movement of the touch since now.
    [panner setTranslation:CGPointZero inView:draggedImage.superview];
    
    CGPoint velocity = [panner velocityInView:self.view];
    if(velocity.y < -100)
    {
        _direction = TOP;
    }
    
    if(panner.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"distance: %f", distance);
        if(_direction == TOP && (distance > 150))
        {

            [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         draggedImage.center = CGPointMake(draggedImage.center.x, -100);
                     }
                    completion:^(BOOL finished){
                                 
                        [self madeItRain:draggedImage];
                    }];
        }
    }
}

-(void)madeItRain:(UIImageView*)draggedImage
{
    int coinValue = [[m_coinValuesArray objectAtIndex:m_currentCoinIndex] integerValue];
    [self sendCoin:coinValue];
    [self resetImages];
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

-(void)horizontalSwipeRecognized:(UIPanGestureRecognizer *)swipe
{
    CGFloat distance = 0;
    CGPoint stopLocation;
    if (swipe.state == UIGestureRecognizerStateBegan)
    {
        _directionAssigned = NO;
        _startLocation = [swipe locationInView:self.view];
    }
    else
    {
        stopLocation = [swipe locationInView:self.view];
        CGFloat dx = stopLocation.x - _startLocation.x;
        CGFloat dy = stopLocation.y - _startLocation.y;
        distance = sqrt(dx*dx + dy*dy);
    }
    
    if(swipe.state == UIGestureRecognizerStateEnded)
    {
        if(_direction == LEFT && (([UIScreen mainScreen].bounds.size.width - _startLocation.x) + distance) > [UIScreen mainScreen].bounds.size.width/2)
        {
            if (m_currentCoinIndex + 1 < [m_coinsArray count])
            {
                m_currentCoinIndex++;
            }
            else
            {
                m_currentCoinIndex = 0;
            }
            
            [self reassignImageViews];
        }
        else if(_direction == RIGHT && _startLocation.x + distance > [UIScreen mainScreen].bounds.size.width/2)
        {
            if (m_currentCoinIndex - 1 >= 0)
            {
                m_currentCoinIndex--;
            }
            else
            {
                m_currentCoinIndex = [m_coinsArray count] - 1;
            }
            
            [self reassignImageViews];
        }
        else
        {
            [self resetImages];
        }
        _reassignIncomingImage = YES;
        return;
    }
    
    CGPoint velocity = [swipe velocityInView:self.view];
    if(velocity.x < -100)//left
    {
        self.m_nextCoinImageView.frame = CGRectMake(self.m_nextCoinImageView.frame.origin.x - distance, self.m_nextCoinImageView.frame.origin.y, self.m_nextCoinImageView.bounds.size.width, self.m_nextCoinImageView.bounds.size.height);
        
        self.m_currentCoinImageView.frame = CGRectMake(self.m_currentCoinImageView.frame.origin.x - distance, self.m_currentCoinImageView.frame.origin.y, self.m_currentCoinImageView.bounds.size.width, self.m_currentCoinImageView.bounds.size.height);
            _direction  = LEFT;
    }
    else if (velocity.x > 100)//right
    {
        self.m_nextCoinImageView.frame = CGRectMake(self.m_nextCoinImageView.frame.origin.x + distance, self.m_nextCoinImageView.frame.origin.y, self.m_nextCoinImageView.bounds.size.width, self.m_nextCoinImageView.bounds.size.height);
        
        self.m_currentCoinImageView.frame = CGRectMake(self.m_currentCoinImageView.frame.origin.x + distance, self.m_currentCoinImageView.frame.origin.y, self.m_currentCoinImageView.bounds.size.width, self.m_currentCoinImageView.bounds.size.height);
            _direction  = RIGHT;
    }
    
    if(_direction == LEFT)
    {
        if(stopLocation.x > _startLocation.x -5) //adjust to avoid snapping
        {
            distance = -distance;
        }
    }
    else
    {
        if(stopLocation.x < _startLocation.x +5) //adjust to avoid snapping
        {
            distance = -distance;
        }
    }
}

-(void)reassignImageViews
{
  if (_direction == LEFT) // swipe left
  {
      int queuedImageIndex = m_currentCoinIndex + 1;
      if (queuedImageIndex >= [m_coinsArray count])
      {
          queuedImageIndex = 0; // wrap index back to front
      }

      if (_activeImage == CURRENT)
      {
          // queue up the next image
          UIImage *currentImage = [m_coinsArray objectAtIndex:queuedImageIndex];
          self.m_currentCoinImageView.image = currentImage;
          self.m_currentCoinImageView.frame = CGRectMake(width, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
          
          // put swiped image back into center
          UIImage *nextImage = [m_coinsArray objectAtIndex:m_currentCoinIndex];
          self.m_nextCoinImageView.image = nextImage;
          [UIView animateWithDuration:.5
                           animations:^{
                               self.m_nextCoinImageView.frame = CGRectMake((width - COIN_WIDTH)/2, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
                           }];
          _activeImage = NEXT;
      }
      else
      {
          // queue up the next image
          UIImage *currentImage = [m_coinsArray objectAtIndex:m_currentCoinIndex];
          self.m_currentCoinImageView.image = currentImage;
          [UIView animateWithDuration:.5
                           animations:^{
                               self.m_currentCoinImageView.frame = CGRectMake((width - COIN_WIDTH)/2, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
          }];
          
          UIImage *nextImage = [m_coinsArray objectAtIndex:queuedImageIndex];
          self.m_nextCoinImageView.frame = CGRectMake(width, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
          self.m_nextCoinImageView.image = nextImage;
          _activeImage = CURRENT;
      }
  }
  else // swipe right
  {
      int queuedImageIndex = m_currentCoinIndex - 1;
      if (queuedImageIndex < 0)
      {
          queuedImageIndex = [m_coinsArray count] - 1; // wrap index back to front
      }
      
      if (_activeImage == CURRENT)
      {
          // queue up the next image
          UIImage *currentImage = [m_coinsArray objectAtIndex:queuedImageIndex];
          self.m_currentCoinImageView.frame = CGRectMake(width, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
          self.m_currentCoinImageView.image = currentImage;
          
          UIImage *nextImage = [m_coinsArray objectAtIndex:m_currentCoinIndex];
          self.m_nextCoinImageView.image = nextImage;
          [UIView animateWithDuration:.5
                           animations:^{
                               self.m_nextCoinImageView.frame = CGRectMake((width - COIN_WIDTH)/2, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
          }];
          _activeImage = NEXT;
      }
      else
      {
          // queue up the next image
          UIImage *currentImage = [m_coinsArray objectAtIndex:m_currentCoinIndex];
          self.m_currentCoinImageView.image = currentImage;
          [UIView animateWithDuration:.5
                           animations:^{
                               self.m_currentCoinImageView.frame = CGRectMake((width - COIN_WIDTH)/2, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
            }];
          
          UIImage *nextImage = [m_coinsArray objectAtIndex:queuedImageIndex];
          self.m_nextCoinImageView.image = nextImage;
          self.m_nextCoinImageView.frame = CGRectMake(width, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
          _activeImage = CURRENT;
      }

  }
}

-(void)resetImages
{
    if (_activeImage == NEXT)
    {
        // queue up the next image
        self.m_currentCoinImageView.frame = CGRectMake(width, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
        self.m_nextCoinImageView.frame = CGRectMake((width- COIN_WIDTH)/2, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
    }
    else
    {
        self.m_currentCoinImageView.frame = CGRectMake((width - COIN_WIDTH)/2, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
        self.m_nextCoinImageView.frame = CGRectMake(width, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
