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
#import "DBManager.h"

@interface RetrieveCoinsViewController ()

@end

@implementation RetrieveCoinsViewController

@synthesize width;
@synthesize height;
@synthesize m_animatingCloudsMap;
@synthesize m_sendCoinsButton;

#define COIN_WIDTH 100
#define COIN_HEIGHT 100

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    width = screenRect.size.width;
    height = screenRect.size.height;
    
    [self setupHubCloud];
    [self setupWallet];
    [self createAnimatingClouds];
    [self retrieveNextCoins];
    
    UIPanGestureRecognizer* verticalPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWasRecognized:)];
    [self.view addGestureRecognizer:verticalPan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) goToSendCoins:(UIButton *)button
{
    [self performSegueWithIdentifier:@"ReceiveToSendSegue" sender:self];
}

- (void) goToStormHistory:(UIButton *) button
{
     [self performSegueWithIdentifier:@"ReceiveToStormHistorySegue" sender:self];
}

- (void) retrieveNextCoins
{
    // retrieve next n coins (sorted by value amt and expiration)
    if (self.m_coinsArray == nil)
    {
        self.m_coinsArray = [[NSMutableArray alloc] init]; // full of Coin objects
    }
    
    if (!self.m_fetchingCoinsFlag)
    {
        [self getPendingCoins];
    }
}

- (void) getPendingCoins
{
    // prevent duplicate calls
    self.m_fetchingCoinsFlag = true;
    
    // send a coin with coinValue to server
    Singleton* appData = [Singleton sharedInstance];
    NSString *urlString = [NSString stringWithFormat:@"%@api/coins/getPending?", appData.serverUrl];
    NSString *postString = [NSString stringWithFormat:@"toUsername=%@", appData.userId];
    
    NSString *fullString = [NSString stringWithFormat:@"%@%@",urlString, postString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setValue:appData.token forHTTPHeaderField:@"X-Auth-Token"];
    
    [request setURL:[NSURL URLWithString:fullString]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", responseString);
        
        self.m_fetchingCoinsFlag = false;
        if (responseString != nil)
        {
            NSMutableArray *coins = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            for (NSArray *coin in coins)
            {
                NSString *coinId = [coin valueForKey:@"id"];
                NSString *fromUser = [coin valueForKey:@"fromUsername"];
                NSString *value = [coin valueForKey:@"value"];
                
                NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
                [doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
                [doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:2];
                NSNumber *dubValue = [doubleValueWithMaxTwoDecimalPlaces numberFromString:value];

                Coin *coin = [[Coin alloc] initWithValue:[dubValue doubleValue] ToUser:appData.userId FromUser:fromUser];
                coin.CoinId = coinId;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.m_coinsArray addObject:coin];
                    
                });

            }
            
            if (self.m_coinImageViewsArray == nil)
            {
                self.m_coinImageViewsArray = [[NSMutableArray alloc] init]; // visual representation of all coins in batch
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupCoinViews];
            });
        }
        
    }] resume];
}

- (void) setupCoinViews
{
    
    for (int i=0; i < self.m_coinsArray.count; i++)
    {
        [self addCoinView:i];
    }
}

- (void) addCoinView:(int)index
{
    Coin* coin = [self.m_coinsArray objectAtIndex:index];
    NSString* imageName = @"";
    if (coin.Value ==.01)
    {
        imageName = @"Coin1.png";
    }
    else if (coin.Value ==.05)
    {
        imageName = @"Couin5.png";
    }
    else if (coin.Value ==.10)
    {
        imageName = @"Coin10.png";
    }
    else if (coin.Value ==.25)
    {
        imageName = @"Coin25.png";
    }
    else
    {
        return;
    }
    UIImageView* coinView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [self randomizeCoinPlacements:coinView];
    [self.m_coinImageViewsArray addObject:coinView];
    
    [self.view insertSubview:coinView belowSubview:self.m_cloudHub];

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

- (void) setupWallet
{
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 3 * (height / 4);
    frame.size.width = width;
    frame.size.height = (height / 4);
    
    self.m_walletBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WalletHalfBack.png"]];
    self.m_walletBackView.frame = frame;
    
    self.m_walletFrontView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WalletHalfFront.png"]];
    frame.origin.y = frame.origin.y + 25;
    frame.origin.x = frame.origin.x + 5;
    
    self.m_walletFrontView.frame = frame;
    
    [self.view addSubview:self.m_walletBackView];
    [self.view addSubview:self.m_walletFrontView];
    
    frame.origin.x = 3 * (width / 4);
    frame.origin.y = 17 * (height / 20);
    frame.size.width = 75;
    frame.size.height = 75;
    
    // setup send coin button
    self.m_sendCoinsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.m_sendCoinsButton addTarget:self action:@selector(goToSendCoins:) forControlEvents:UIControlEventTouchUpInside];
    self.m_sendCoinsButton.frame = frame;
    [self.m_sendCoinsButton setImage:[UIImage imageNamed:@"AddFriendButton.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.m_sendCoinsButton];
    
    frame.origin.x = width / 4 - 75;
    frame.size.height = 75;
    frame.size.width = 75;
    
    // setup storm history button
    self.m_stormHistoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.m_stormHistoryButton addTarget:self action:@selector(goToStormHistory:) forControlEvents:UIControlEventTouchUpInside];
    [self.m_stormHistoryButton setImage:[UIImage imageNamed:@"LauncherIcon.png"] forState:UIControlStateNormal];

    self.m_stormHistoryButton.frame = frame;
    [self.view addSubview:self.m_stormHistoryButton];
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
    self.m_sunBackButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Sun.png"]];
    CGRect sunFrame;
    sunFrame.origin.x = 0 - 30;
    sunFrame.origin.y = 0 - 30;
    sunFrame.size.width = width / 3;
    sunFrame.size.height = width / 3;
    
    self.m_sunBackButton.frame = sunFrame;
    
    [self.m_sunBackButton setUserInteractionEnabled:YES];
    [self.view addSubview:self.m_sunBackButton];
    [self.view addSubview:self.m_cloudHub];
    [self.view addSubview:self.m_beneathCloud];
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

-(void)sunTouched:(UITapGestureRecognizer *)tap
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    
    if (self.m_coinImageViewsArray.count == 1)
    {
        [self retrieveNextCoins];
    }
    
    UIImageView *currentCoin = [self.m_coinImageViewsArray objectAtIndex:0];
    Coin *coin = [self.m_coinsArray objectAtIndex:0];
    //NSLog(@"Coin: %@", coin.Value);
    
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
        
        BOOL successful = false;
        if(currentCoin.center.y < height * .40) // unsuccessful coin fling, coin flies up
        {
            projectedX = currentCoin.center.x + dx*2;
            projectedY = 0 - COIN_HEIGHT;
        }
        else // successful fling, coin falls
        {
            projectedX = currentCoin.center.x + dx*2;
            projectedY = height + COIN_HEIGHT;
            successful = true;
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
        
        if (successful)
        {
            [self coinRetrieved:coin];
        }
        
        // remove flung coin from current array, add to animated array
        [self.m_currentlyAnimatingCoinsArray addObject:currentCoin];
        [self.m_coinImageViewsArray removeObjectAtIndex:0];
        [self.m_coinsArray removeObjectAtIndex:0];
        
        /*if (!successful)
        {
            [self.m_coinsArray addObject:currentCoin];
            [self addCoinView:(int)self.m_coinsArray.count - 1];
        }*/
    }
}

- (void) coinRetrieved:(Coin *)currentCoin
{
    // send a coin with coinValue to server
    Singleton* appData = [Singleton sharedInstance];
    
    NSString *urlString = [NSString stringWithFormat:@"%@api/coins/%@", appData.serverUrl, currentCoin.CoinId];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:appData.token forHTTPHeaderField:@"X-Auth-Token"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (response != nil)
         {
             NSDictionary *allJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
             NSString *senderProfUrl = [allJSON objectForKey:@"fromUserProfilePictureUrl"];
             currentCoin.SenderProfUrl = senderProfUrl;
             
             // display custom toast
             [self displayToast:currentCoin];
         }
     }];
}

- (void) displayToast:(Coin*)coin
{
    UIImage *profImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:coin.SenderProfUrl]]];
    UIImageView *senderProf = [[UIImageView alloc] initWithImage:profImage];
    senderProf.frame = CGRectMake(10, 3 * (height / 4) - 50, 50, 50);
    [Utils circlize:profImage withImageView:senderProf];
    
    NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
    [doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
    [doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:2];
    NSNumber *dubValue = [doubleValueWithMaxTwoDecimalPlaces numberFromString:[NSString stringWithFormat:@"%f", coin.Value]];
    
    UILabel *toastLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 3 * (height / 4) - 50, width - 50, 50)];
    toastLabel.text = [NSString stringWithFormat:@"%@ sent you $%@", coin.SenderId, [dubValue stringValue]];
    toastLabel.font = [UIFont systemFontOfSize:15];
    toastLabel.textColor = [UIColor whiteColor];
    
    [self.view addSubview:senderProf];
    [self.view addSubview:toastLabel];
    
    [UIView animateWithDuration:2.0
                          delay:0.0
                        options:UIViewAnimationCurveLinear
                     animations:^{
                         toastLabel.alpha = .0;
                         toastLabel.center = CGPointMake(toastLabel.center.x, toastLabel.frame.origin.y - 50);
                         senderProf.alpha = .0;
                         senderProf.center = CGPointMake(senderProf.center.x, senderProf.frame.origin.y - 50);
                     }
                     completion:^(BOOL finished){
                         [toastLabel removeFromSuperview];
                         [senderProf removeFromSuperview];
                     }];
}


@end
