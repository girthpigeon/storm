//
//  MakeItRainViewController.m
//  storm
//
//  Created by Zack Pajka on 6/16/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "MakeItRainViewController.h"

@implementation MakeItRainViewController

NSMutableArray *m_coinsArray;
int m_currentCoinIndex = 0;
CGPoint _startLocation;
BOOL _directionAssigned = NO;
enum direction {LEFT,RIGHT};
enum direction _direction;
enum activeImageView {CURRENT,NEXT};
enum activeImageView _activeImage = CURRENT;
BOOL _reassignIncomingImage = YES;

#define COIN_WIDTH 100
#define COIN_HEIGHT 100

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.m_coinChoosingScrollView.delegate = self;
    [self createCoinsArray];
    //[self.m_coinChoosingScrollView setContentSize:CGSizeMake([self.m_coinsArray count] * self.view.bounds.size.width, self.view.bounds.size.height)];
    
    UIImage *currentImage = [m_coinsArray objectAtIndex:m_currentCoinIndex];
    self.m_currentCoinImageView.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
    self.m_currentCoinImageView.image = currentImage;
    
    UIImage *nextImage = [m_coinsArray objectAtIndex:m_currentCoinIndex+1];
    self.m_nextCoinImageView.frame = CGRectMake(self.view.bounds.size.width, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
    self.m_nextCoinImageView.image = nextImage;
    
    [self.view addSubview:self.m_currentCoinImageView];
    [self.view addSubview:self.m_nextCoinImageView];
    
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(horizontalSwipeRecognized:)];
    [self.view addGestureRecognizer:pan];
    
}

- (void)createCoinsArray
{
    m_coinsArray =[[NSMutableArray alloc]init];
    
    [m_coinsArray  addObject:[UIImage imageNamed:@"Coin1.png"]];
    [m_coinsArray  addObject:[UIImage imageNamed:@"Couin5.png"]];
    [m_coinsArray  addObject:[UIImage imageNamed:@"Coin10.png"]];
    [m_coinsArray  addObject:[UIImage imageNamed:@"Coin25.png"]];
}

- (void)panWasRecognized:(UIPanGestureRecognizer *)panner {
    UIView *draggedView = panner.view;
    CGPoint offset = [panner translationInView:draggedView.superview];
    CGPoint center = draggedView.center;
    draggedView.center = CGPointMake(center.x + offset.x, center.y + offset.y);
    
    // Reset translation to zero so on the next `panWasRecognized:` message, the
    // translation will just be the additional movement of the touch since now.
    [panner setTranslation:CGPointZero inView:draggedView.superview];
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
          self.m_currentCoinImageView.frame = CGRectMake(self.view.bounds.size.width, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
          
          // put swiped image back into center
          UIImage *nextImage = [m_coinsArray objectAtIndex:m_currentCoinIndex];
          self.m_nextCoinImageView.image = nextImage;
          self.m_nextCoinImageView.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
      }
      else
      {
          // queue up the next image
          UIImage *currentImage = [m_coinsArray objectAtIndex:m_currentCoinIndex];
          self.m_currentCoinImageView.image = currentImage;
          self.m_currentCoinImageView.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
          
          UIImage *nextImage = [m_coinsArray objectAtIndex:queuedImageIndex];
          self.m_nextCoinImageView.frame = CGRectMake(self.view.bounds.size.width, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
          self.m_nextCoinImageView.image = nextImage;
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
          self.m_currentCoinImageView.frame = CGRectMake(self.view.bounds.size.width, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
          self.m_currentCoinImageView.image = currentImage;
          
          UIImage *nextImage = [m_coinsArray objectAtIndex:m_currentCoinIndex];
          self.m_nextCoinImageView.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
          self.m_nextCoinImageView.image = nextImage;
      }
      else
      {
          // queue up the next image
          UIImage *currentImage = [m_coinsArray objectAtIndex:m_currentCoinIndex];
          self.m_currentCoinImageView.image = currentImage;
          self.m_currentCoinImageView.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
          
          UIImage *nextImage = [m_coinsArray objectAtIndex:queuedImageIndex];
          self.m_nextCoinImageView.image = nextImage;
          self.m_nextCoinImageView.frame = CGRectMake(self.view.bounds.size.width, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
          
      }

  }
}

-(void)resetImages
{
    if (_activeImage == NEXT)
    {
        // queue up the next image
        self.m_currentCoinImageView.frame = CGRectMake(self.view.bounds.size.width, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
        self.m_nextCoinImageView.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
    }
    else
    {
        self.m_currentCoinImageView.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
        self.m_nextCoinImageView.frame = CGRectMake(self.view.bounds.size.width, self.view.bounds.size.height/2, COIN_WIDTH, COIN_HEIGHT);
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
