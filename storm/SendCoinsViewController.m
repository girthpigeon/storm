//
//  SendCoinsViewController.m
//  storm
//
//  Created by Zack Pajka on 8/24/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "SendCoinsViewController.h"
#import "Singleton.h"
#import "Friend.h"
#import "Utils.h"

@implementation SendCoinsViewController

NSMutableArray *m_coinsArray;
NSMutableArray *m_coinValuesArray;
NSMutableArray *m_coinViewsArray;
NSMutableArray *m_coinImageViewsArray;

NSMutableArray *m_currentlyAnimatingCoinsArray;
NSMutableDictionary *m_animatingCloudsMap;

UITableView *m_friendsList;
NSMutableArray *m_friendsArray;
BOOL m_friendPickerActivated;

NSData *m_responseData;

// wallet
UIImageView *m_walletFrontView;
UIImageView *m_walletBackView;
CGPoint m_walletFrontViewLocation;
CGPoint m_walletBackViewLocation;

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
    
    [self setupBackground];
    //[self setupFriendListview];
    [self createCoinsArray];
    [self setupCoinViews];
    [self setupHubCloud];
    
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

- (void) setupFriendListview
{
    m_friendsList=[[UITableView alloc]init];
    m_friendsList.frame = CGRectMake(0,height,width, height /2);
    m_friendsList.dataSource=self;
    m_friendsList.delegate=self;
    m_friendsList.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [m_friendsList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [m_friendsList reloadData];
    [self.view addSubview:m_friendsList];
    
    UITapGestureRecognizer *dismissFriends = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFriendsPicker:)];
    [dismissFriends setDelegate:self];
    
    [self.view setUserInteractionEnabled:YES];
    
    [self.view addGestureRecognizer:dismissFriends];
}

- (void) setupBackground
{
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 3 * (height / 4);
    frame.size.width = width;
    frame.size.height = (height / 4);
    
    m_walletBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WalletHalfBack.png"]];
    m_walletBackView.frame = frame;
    
    m_walletFrontView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WalletHalfFront.png"]];
    frame.origin.y = frame.origin.y + 25;
    frame.origin.x = frame.origin.x + 5;
    
    m_walletFrontView.frame = frame;
    
    [self.view addSubview:m_walletBackView];
    [self.view addSubview:m_walletFrontView];
    
    [self createAnimatingClouds];
}

- (void) createAnimatingClouds
{
    int numClouds = 3;
    
    int lowerBound = 1;
    int upperBound = 5;
    int rndNumClouds = lowerBound + arc4random() % (upperBound - lowerBound);
    
    for (int i=0; i < rndNumClouds; i++)
    {
        m_animatingCloudsMap = [[NSMutableDictionary alloc] initWithCapacity:numClouds];
        NSString *tag = [NSString stringWithFormat:@"%d?", i];
        [self createCloud:tag fromEdge:false];
    }
}

-(void) createCloud:(NSString*) tag fromEdge:(BOOL) onEdge
{
    // setup animating clouds
    UIImageView *cloudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainCloud.png"]];
    CGRect frame;
    
    int lowerBound = 0;
    int upperBound = width;
    int rndX = lowerBound + arc4random() % (upperBound - lowerBound);
    
    lowerBound = height / 4;
    upperBound = 2 * (height / 3);
    int rndY = lowerBound + arc4random() % (upperBound - lowerBound);
    
    lowerBound = width / 5;
    upperBound = width / 2;
    int rndWidth = lowerBound + arc4random() % (upperBound - lowerBound);
    
    lowerBound = height / 10;
    upperBound = height / 6;
    int rndHeight = lowerBound + arc4random() % (upperBound - lowerBound);
    
    if (onEdge)
    {
        rndX = 0 - rndWidth;
    }
    
    frame.origin.x = rndX;
    frame.origin.y = rndY;
    frame.size.width = rndWidth;
    frame.size.height = rndHeight;
    
    cloudView.frame = frame;
    cloudView.alpha = .4;
    
    [self.view addSubview:cloudView];
    [self animateCloud:cloudView withTag:tag];
    [self.view sendSubviewToBack:cloudView];
    
}

- (void) animateCloud:(UIImageView*) cloudView withTag:(NSString*) tag
{
    // animation
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // Move the "cursor" to the start
    [path moveToPoint:cloudView.center];
    
    CGFloat projectedX = width + cloudView.frame.size.width;
    CGFloat projectedY = cloudView.frame.origin.y;
    
    // set animation endpoint
    CGPoint finishPoint = CGPointMake(projectedX, projectedY);
    
    int lowerBound = 5.0;
    int upperBound = 15.0;
    int rndDuration = lowerBound + arc4random() % (upperBound - lowerBound);
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    // Draw a curve towards the end, using control points
    [path addCurveToPoint:finishPoint controlPoint1:finishPoint controlPoint2:finishPoint];
    
    // Use this path as the animation's path (casted to CGPath)
    pathAnimation.path = path.CGPath;
    
    // The other animations properties
    pathAnimation.fillMode              = kCAFillModeForwards;
    pathAnimation.removedOnCompletion   = NO;
    pathAnimation.duration              = rndDuration;
    pathAnimation.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // Apply it
    [pathAnimation setDelegate:self];
    [pathAnimation setValue:@"cloud" forKey:@"tag"];
    [pathAnimation setValue:tag forKey:@"cloudId"];
    [cloudView.layer addAnimation:pathAnimation forKey:@"cloudMove"];
    
    // add to animating clouds map
    [m_animatingCloudsMap setObject:cloudView forKey:tag];
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
    [self.horizontalScrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.horizontalScrollView];
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
    
    UITapGestureRecognizer *hubTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cloudHubTouched:)];
    [hubTouch setDelegate:self];
    
    [cloudView setUserInteractionEnabled:YES];
    
    
    [self.view addSubview:cloudView];
    
    // to whom textblock
    UILabel *toLabel = [[UILabel alloc]initWithFrame:CGRectMake((width / 2) - (width / 6), height / 20, width / 3, (height / 20) * 2)];
    toLabel.text = @"To:";
    [toLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.view addSubview:toLabel];
    
    UIImageView *prof = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProfilePictureHolder.png"]];
    
    frame.origin.x = width /2 + width / 5;
    frame.origin.y = (height / 20) * 3;
    frame.size.width = 100;
    frame.size.height = 100;
    prof.frame = frame;
    
    UITapGestureRecognizer *friendPickerTouched = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickFriendsTouched:)];
    [friendPickerTouched setDelegate:self];
    
    [prof setUserInteractionEnabled:YES];
    
    [self.view addSubview:prof];
    
    [cloudView addGestureRecognizer:hubTouch];
    [prof addGestureRecognizer:friendPickerTouched];
    
    // message edittextbox
    //UITextField *message = [[UITextField alloc]initWithFrame:CGRectMake((width / 2) - (width / 6), (height / 20) * 2, width / 3, (height / 20) * 2)];
    //[message setBorderStyle:UITextBorderStyleRoundedRect];
    //[self.view addSubview:message];
    
    // friend picker
    
}

-(void)cloudHubTouched:(UITapGestureRecognizer *)tap
{
    // edit message
}

-(void) pickFriendsTouched:(UITapGestureRecognizer *)tap
{
    if (!m_friendPickerActivated)
    {
        // fetch venmo friends
        [self getFriendsList];
        
        // setup the friends listview
        [self setupFriendListview];
   
        // slide wallet down
        [self changeFriendPickerStatus:true];
        
    }
   
}

-(void)changeFriendPickerStatus:(BOOL) down
{
    if (down)
    {
        m_walletBackViewLocation = m_walletBackView.center;
        m_walletFrontViewLocation = m_walletFrontView.center;
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveLinear
                         animations:^{
                             m_walletBackView.center = CGPointMake(m_walletBackView.center.x, height * 2);
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveLinear
                         animations:^{
                             m_walletFrontView.center = CGPointMake(m_walletFrontView.center.x, height * 2);
                         }
                         completion:^(BOOL finished){
                             
                             
                         }];
        
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveLinear
                         animations:^{
                             m_friendsList.center = CGPointMake(width / 2, height / 2);
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        m_friendPickerActivated = true;
    }
    else
    {
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveLinear
                         animations:^{
                             m_walletBackView.center = m_walletBackViewLocation;
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveLinear
                         animations:^{
                             m_walletFrontView.center = m_walletFrontViewLocation;
                         }
                         completion:^(BOOL finished){
                             
                         }];
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveLinear
                         animations:^{
                             m_friendsList.center = CGPointMake(width / 2, height * 2);
                         }
                         completion:^(BOOL finished){
                             
                         }];
        m_friendPickerActivated = false;
    }
}

- (void) dismissFriendsPicker:(UITapGestureRecognizer *)tap
{
    if (m_friendPickerActivated)
    {
        [self changeFriendPickerStatus:false];
    }
}

-(void)getFriendsList
{
    m_friendsArray = [[NSMutableArray alloc] init];
    
    // send a coin with coinValue to server
    Singleton* appData = [Singleton sharedInstance];
    NSString *urlString = [NSString stringWithFormat:@"%@User/getMyVenmoFriends?", appData.serverUrl];
    
    //http://localhost:1337/User/getMyVenmoFriends?userId=558746ccd1e77f4a2a9a0d91&stormKey=558746ccd1e77f4a2a9a0d92
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"userId=%@&stormKey=%@", appData.userId, appData.stormId];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]] forHTTPHeaderField:@"Content-length"];
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    //NSString* accessToken = @"853ca506cae4b0a19c8d442d34e85e1c47a36139bc3ee07713f5b33d1663599c";
    
    //NSError *err;
    
    //NSURLResponse *response;
    
    //NSData *responseData = [NSURLConnection sendSynchronousRequest:request   returningResponse:&response error:&err];
    
    //NSDictionary *jsonArray = [NSJSONSerialization JSONObjectWithData:responseData options: NSJSONReadingMutableContainers error: &err];
    
   // NSArray *array=[[jsonArray objectForKey:@"search_api"]objectForKey:@"result"];

    
    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

// This method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    //NSArray *jsonArray=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    //BOOL danger=[(NSNumber*)[(NSDictionary*)[jsonArray objectAtIndex:0] objectForKey:@"danger"] boolValue];
    
    m_responseData = [[NSMutableData alloc] init];
}

// This method receives the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

// This method is used to process the data after connection has made successfully.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:m_responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    if (responseString != nil)
    {
        NSError *e = nil;
        NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error: &e];
        
        if ([JSON count] == 2)
        {
            NSString *username = [JSON objectForKey:@"username"];
            NSString *firstName = [JSON objectForKey:@"first_name"];
            NSString *lastName = [JSON objectForKey:@"last_name"];
            NSString *profUrl = [JSON objectForKey:@"profile_picture_url"];
            Friend *pal = [[Friend alloc] initWithFirst:firstName Last:lastName Username:username ProfUrl:profUrl];
            [m_friendsArray addObject:pal];
        }
    }
    
    //[Utils circlize:(UIImage *) withFrame:<#(CGRect)#>]
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_friendsArray.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier   forIndexPath:indexPath] ;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Friend* pal =[m_friendsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = pal.FirstName;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Your custom operation
}

- (void)resetCoinViews
{
    m_coinViewsArray = [[NSMutableArray alloc] init];
    m_coinImageViewsArray = [[NSMutableArray alloc] init];
    m_currentlyAnimatingCoinsArray = [[NSMutableArray alloc] init];
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
        frame = CGRectMake(coinXPosition, 2 * (height/3), COIN_WIDTH, COIN_HEIGHT);
        
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
            if (m_currentCoinIndex < m_coinViewsArray.count - 1)
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
        }
        else if (m_scrollDirection == Right)
        {
            if (m_currentCoinIndex > 0)
            {
                for (int i = (int)m_coinViewsArray.count - 1; i >= 0; i--)
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
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    m_finishedPaginate = true;
}

- (void)panWasRecognized:(UIPanGestureRecognizer *)panner {
    if (m_friendPickerActivated)
    {
        [self changeFriendPickerStatus:false];
        return;
    }
    
    CGFloat distance = 0;
    CGPoint stopLocation;
    CGFloat dx = 0.0;
    CGFloat dy = 0.0;
    
    UIImageView *currentCoin = [m_coinImageViewsArray objectAtIndex:m_currentCoinIndex];
    
    if (panner.state == UIGestureRecognizerStateBegan)
    {
        m_startPosition = [panner locationInView:self.view];
        //currentCoin =[m_coinImageViewsArray objectAtIndex:m_currentCoinIndex];
    }
    else
    {
        stopLocation = [panner locationInView:self.view];
        dx = stopLocation.x - m_startPosition.x;
        dy = stopLocation.y - m_startPosition.y;
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
        
        [self madeItRain:currentCoin];
        
        // remove flung coin from current array, add to animated array
        [m_currentlyAnimatingCoinsArray addObject:currentCoin];
        [m_coinImageViewsArray removeObjectAtIndex:m_currentCoinIndex];
        
        // add new copy of coin to center
        float coinXPosition = (width/2) - COIN_WIDTH/2;
        CGRect frame = CGRectMake(coinXPosition, 2 * (height/3), COIN_WIDTH, COIN_HEIGHT);
        
        UIImageView *coinImageView = [[UIImageView alloc] initWithFrame:frame];
        UIImage *newImage = [m_coinsArray objectAtIndex:m_currentCoinIndex];
        coinImageView.image = newImage;
        [m_coinImageViewsArray insertObject:coinImageView atIndex:m_currentCoinIndex];
        
        UIView *currentView = [m_coinViewsArray objectAtIndex:m_currentCoinIndex];
        [currentView addSubview:coinImageView];
    }
}

- (void)animationDidStop:(CAKeyframeAnimation *)anim finished:(BOOL)flag
{
    NSString *animationTag = [anim valueForKey:@"tag"];
    
    if ([animationTag isEqualToString:@"coinFling"])
    {
        if (m_currentlyAnimatingCoinsArray.count > 0)
        {
            UIImageView *currentCoin = [m_currentlyAnimatingCoinsArray objectAtIndex:0];
            [m_currentlyAnimatingCoinsArray removeObjectAtIndex:0];
            [currentCoin removeFromSuperview];
        }
    }
    else if ([animationTag isEqualToString:@"cloud"])
    {
        NSString *cloudId = [anim valueForKey:@"cloudId"];
        UIImageView *cloudView = [m_animatingCloudsMap objectForKey:cloudId];
        [cloudView removeFromSuperview];
        [m_animatingCloudsMap removeObjectForKey:cloudId];
        [self createCloud:cloudId fromEdge:true];
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
