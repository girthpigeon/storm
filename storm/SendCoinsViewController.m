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
#import "FriendCell.h"
#import "Storm.h"
#import "Coin.h"

@implementation SendCoinsViewController

// coin arrays
NSMutableArray *m_coinsArray;
NSMutableArray *m_coinValuesArray;
NSMutableArray *m_coinViewsArray;
NSMutableArray *m_coinImageViewsArray;
NSMutableArray *m_currentlyAnimatingCoinsArray;

NSMutableDictionary *m_animatingCloudsMap;

// friend search
UITextField *m_friendSearchBox;
CGFloat const searchHeight = 40;
bool m_searchingFriends = false;
NSMutableArray *m_copyOfFriendsArray;

// friend picker
UITableView *m_friendsListTable;
NSMutableArray *m_friendsArray;
BOOL m_friendPickerActivated;
Friend *m_recipient;

NSMutableData *m_responseData;

// cloudhub
UITextField *m_messageTextField;
UILabel *m_coinCountLabel;
UIImageView *m_recipientImage;
double m_coinCount;

// wallet
UIImageView *m_walletFrontView;
UIImageView *m_walletBackView;
CGPoint m_walletFrontViewLocation;
CGPoint m_walletBackViewLocation;

// current storm
Storm *m_currentStorm;

int m_originalRequestLength;

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
    m_friendsListTable = [[UITableView alloc] init];
    m_friendsListTable.frame = CGRectMake(0, height, width, height /2);
    m_friendsListTable.dataSource=self;
    m_friendsListTable.delegate=self;
    m_friendsListTable.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [m_friendsListTable reloadData];
    [self.view addSubview:m_friendsListTable];
    
    UITapGestureRecognizer *dismissFriends = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapRecognizer:)];
    [dismissFriends setDelegate:self];
    [dismissFriends setCancelsTouchesInView:NO];
    
    [self.view setUserInteractionEnabled:YES];
    
    [self.view addGestureRecognizer:dismissFriends];
    
    // setup search bar on top
    m_friendSearchBox = [[UITextField alloc] init];
    m_friendSearchBox.frame = CGRectMake(0, height / 2, width, 0);
    [m_friendSearchBox setBackgroundColor:[UIColor whiteColor]];
    m_friendSearchBox.delegate = self;
    m_friendSearchBox.tag = 2;
    m_friendSearchBox.alpha = 0.0;
    m_friendSearchBox.autocorrectionType = UITextAutocorrectionTypeNo;
    m_friendSearchBox.returnKeyType = UIReturnKeyDone;
    m_friendSearchBox.placeholder = @"Search for friend";
    [m_friendSearchBox addTarget:self action:@selector(friendSearchChanged:) forControlEvents:UIControlEventEditingChanged];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    m_friendSearchBox.leftView = paddingView;
    m_friendSearchBox.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:m_friendSearchBox];
    
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
    
    [m_coinValuesArray  addObject:[NSNumber numberWithDouble:0.01]];
    [m_coinValuesArray  addObject:[NSNumber numberWithDouble:0.05]];
    [m_coinValuesArray  addObject:[NSNumber numberWithDouble:0.10]];
    [m_coinValuesArray  addObject:[NSNumber numberWithDouble:0.25]];
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
    
    // num coins sent label
    m_coinCountLabel = [[UILabel alloc]initWithFrame:CGRectMake((width / 2) - (width / 6), (height / 25) * 2, width / 2, (height / 20) * 2)];
    m_coinCountLabel.text = @"$0.00";
    m_coinCount = 0.00;
    
    [m_coinCountLabel setFont:[UIFont boldSystemFontOfSize:35]];
    m_coinCountLabel.transform = CGAffineTransformScale(m_coinCountLabel.transform, 0.5, 0.5);
    [self.view addSubview:m_coinCountLabel];
    [self changeCoinCountLabel:m_coinCountLabel.text];
    
    // message edittextbox
    m_messageTextField = [[UITextField alloc]initWithFrame:CGRectMake((width / 6), (height / 30) * 4, (width / 20) * 11, (height / 20) * 3)];
    m_messageTextField.text = @"for being a little baby bitch";
    [m_messageTextField setFont:[UIFont boldSystemFontOfSize:12]];
    [m_messageTextField setBackgroundColor:[UIColor clearColor]];

    m_messageTextField.borderStyle = UITextBorderStyleNone;
    [self.view addSubview:m_messageTextField];
    
    // recipient circle
    m_recipientImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProfilePictureHolder.png"]];
    
    frame.origin.x = width /2 + width / 5;
    frame.origin.y = (height / 20) * 3;
    frame.size.width = 75;
    frame.size.height = 75;
    m_recipientImage.frame = frame;
    
    UITapGestureRecognizer *friendPickerTouched = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickFriendsTouched:)];
    [friendPickerTouched setDelegate:self];
    
    [m_recipientImage setUserInteractionEnabled:YES];
    
    [self.view addSubview:m_recipientImage];
    
    [cloudView addGestureRecognizer:hubTouch];
    [m_recipientImage addGestureRecognizer:friendPickerTouched];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [m_messageTextField resignFirstResponder];
        [m_friendSearchBox resignFirstResponder];
    }
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
        if (!m_friendsArray || m_friendsArray.count == 0)
        {
            [self getFriendsList];
        }
        else
        {
            m_friendsArray = m_copyOfFriendsArray;
            [m_friendsListTable reloadData];
        }
        
        // setup the friends listview
        [self setupFriendListview];
   
        // slide wallet down
        [self changeFriendPickerStatus:true];
        
    }
}

-(void)friendSearchChanged :(UITextField *)theTextField
{
    NSString *search = theTextField.text;
    if ([search isEqualToString:@""])
    {
        m_friendsArray = m_copyOfFriendsArray;
        [m_friendsListTable reloadData];
    }
    else
    {
        NSMutableArray *searchArray = [[NSMutableArray alloc] init];
        for (Friend *pal in m_copyOfFriendsArray)
        {
            if ([pal.FullName containsString:theTextField.text])
            {
                [searchArray addObject:pal];
            }
        }
    
        if (searchArray.count > 0)
        {
            m_friendsArray = searchArray;
            [m_friendsListTable reloadData];
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == m_friendSearchBox.tag)
    {
        m_searchingFriends = true;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == m_friendSearchBox.tag)
    {
    //    m_searchingFriends = false;
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

        CGRect frame = m_friendsListTable.frame;
        frame.origin.y = height / 2;
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveLinear
                         animations:^
                        {
                             m_friendsListTable.frame = frame;
                        }
                        completion:^(BOOL finished)
                        {
                            CGRect frame = m_friendSearchBox.frame;
                            frame.size.height = searchHeight;
                            frame.origin.y = height / 2 - searchHeight;
                             
                            [UIView animateWithDuration:0.2
                                                   delay:0.0
                                                 options:UIViewAnimationCurveLinear
                                              animations:^{
                                                  m_friendSearchBox.alpha = .8;
                                                  m_friendSearchBox.frame = frame;
                                              }
                                              completion:^(BOOL finished){
                                                  
                                              }];
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
        
        CGRect frame = m_friendSearchBox.frame;
        frame.size.height = 0;
        frame.origin.y = height / 2;
        
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:UIViewAnimationCurveLinear
                         animations:^{
                             m_friendSearchBox.frame = frame;
                             m_friendSearchBox.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.4
                                                   delay:0.0
                                                 options:UIViewAnimationCurveLinear
                                              animations:^{
                                                  m_friendsListTable.center = CGPointMake(width / 2, height * 2);
                                              }
                                              completion:^(BOOL finished){
                                                  
                                              }];

                         }];
        
               m_friendPickerActivated = false;
    }
}

- (void) backgroundTapRecognizer:(UITapGestureRecognizer *)tap
{
    if (m_friendPickerActivated && !m_searchingFriends)
    {
        CGPoint touchPoint = [tap locationInView: tap.view];
        if (touchPoint.y < height / 2 - searchHeight)
        {
            [self dismissFriendsPicker];
        }
    }
    
    // no longer focused on friends search box
    if (m_searchingFriends)
    {
        m_searchingFriends = false;
    }
}

- (void) dismissFriendsPicker
{
    [self changeFriendPickerStatus:false];
}

-(void)fetchMoreFriends:(NSString *)requestUrl withNextId:(NSString*)nextId
{
    if (nextId != nil)
    {
        // If we need to remove the previous beforeId
        if (m_originalRequestLength != requestUrl.length)
        {
            NSRange range = NSMakeRange(0, m_originalRequestLength);
            requestUrl = [requestUrl substringWithRange:range];
        }
        requestUrl = [NSString stringWithFormat:@"%@&beforeId=%@", requestUrl, nextId];
    }
    else
    {
        m_originalRequestLength = (int)requestUrl.length;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:requestUrl]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", responseString);
        
        if (responseString != nil)
        {
            NSDictionary *allJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSDictionary *result = [allJSON objectForKey:@"result"];

            NSString *nextUrl = [result objectForKey:@"pagination"];
            
            NSMutableArray *friends = [result objectForKey:@"data"];
            for (NSArray *friend in friends)
            {
                NSString *username = [friend valueForKey:@"username"];
                NSString *firstName = [friend valueForKey:@"first_name"];
                NSString *lastName = [friend valueForKey:@"last_name"];
                NSString *profUrl = [friend valueForKey:@"profile_picture_url"];
                Friend *pal = [[Friend alloc] initWithFirst:firstName Last:lastName Username:username ProfUrl:profUrl];
                [m_friendsArray addObject:pal];
                m_copyOfFriendsArray = [[NSMutableArray alloc] initWithArray:m_friendsArray];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [m_friendsListTable reloadData];
                });
            }
            
            if (![nextUrl isEqualToString:@""])
            {
                NSLog(@"fetchingmorefriends: %@", nextUrl);
                [self fetchMoreFriends:requestUrl withNextId:nextUrl];
            }
            else
            {
                NSLog(@"all done");
            }
        }
        
    }] resume];

}

-(void)getFriendsList
{
    m_friendsArray = [[NSMutableArray alloc] init];
    
    // send a coin with coinValue to server
    Singleton* appData = [Singleton sharedInstance];
    NSString *urlString = [NSString stringWithFormat:@"%@User/getMyVenmoFriends?", appData.serverUrl];
    NSString *postString = [NSString stringWithFormat:@"userId=%@&stormKey=%@", appData.userId, appData.stormId];
    
    NSString *fullString = [NSString stringWithFormat:@"%@%@",urlString, postString];
    [self fetchMoreFriends:fullString withNextId:nil];
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
    static NSString *CellIdentifier = @"FriendCell";
    FriendCell *cell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Friend* pal =[m_friendsArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = pal.FullName;
    [Utils circlize:pal.ProfPic withImageView:cell.thumbnailImageView];
    
    cell.thumbnailImageView.image = pal.ProfPic;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    m_recipient =[m_friendsArray objectAtIndex:indexPath.row];
    [self changeRecipient];
    [self dismissFriendsPicker];
}

- (void) changeRecipient
{
    [Utils circlize:m_recipient.ProfPic withImageView:m_recipientImage];
    [self initializeNewStorm];
}

-(void) initializeNewStorm
{
    m_messageTextField.text = @"";
    m_coinCountLabel.text = @"$0.00";
    Singleton* appData = [Singleton sharedInstance];
    m_currentStorm = [[Storm alloc] init:m_recipient withSender:appData.userId];
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
        
        if(currentCoin.center.y < height * .65) // successful coin fling, coin flies up
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
    double coinValue = [[m_coinValuesArray objectAtIndex:m_currentCoinIndex] doubleValue];
    NSString* newAmt = [self convertCoinValueToMoneyAmount:m_coinCountLabel.text plus:coinValue];
    [self changeCoinCountLabel:newAmt];
    [self sendCoin:coinValue];
    [self resetImage];
    
}

-(NSString *)convertCoinValueToMoneyAmount:(NSString *)currentAmtString plus:(double)coinValue
{
    // convert string to double
    NSString *value = [currentAmtString substringFromIndex:1];
    double startingValue = [value doubleValue];
    
    // add doubles
    startingValue += coinValue;
    
    // convert back to string
    return [NSString stringWithFormat:@"$%.02f", startingValue];
}

-(void)changeCoinCountLabel:(NSString *)value
{
    [UIView animateWithDuration:.1 animations:^{
        m_coinCountLabel.transform = CGAffineTransformScale(m_coinCountLabel.transform, 2, 2);
        
    } completion:^(BOOL finished){
        
        [self.view addSubview:m_coinCountLabel];
        [UIView animateWithDuration:.4 animations:^{
            m_coinCountLabel.transform = CGAffineTransformScale(m_coinCountLabel.transform, 0.5, 0.5);
        }];
    }];
    
    m_coinCountLabel.text = value;
}

-(void)sendCoin:(int) coinValue
{
    // send a coin with coinValue to server
    Singleton* appData = [Singleton sharedInstance];
    
    NSString *defaultMessage = @"Ryan sucks eggs";
    //NSString *defaultToUser = @"558746ccd1e77f4a2a9a0d92";
    NSString *defaultToUser = @"1";
    //NSString *sandboxUser = @"145434160922624933";
    NSString *sandboxUser = @"6";
    
    NSString *urlString = [NSString stringWithFormat:@"%@Coin/sendCoin?", appData.serverUrl];
    //NSString *fullUrl = [NSString stringWithFormat:@"%@from=%@&to=%@&value=%d&message=%@&stormKey=%@", urlString, sandboxUser, defaultToUser, coinValue, defaultMessage, appData.stormId];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"from=%@&to=%@&value=%d&message=%@&stormKey=%@", sandboxUser, defaultToUser, coinValue, defaultMessage, appData.stormId];
    
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(connection) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection could not be made");
    }
    
}

-(void)resetImage
{
    //UIImageView *currentView = [m_coinViewsArray objectAtIndex:m_currentCoinIndex];
    //self.m_currentCoinImageView.frame = CGRectMake(width, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
    //self.m_nextCoinImageView.frame = CGRectMake((width- COIN_WIDTH)/2, (2 * height)/3, COIN_WIDTH, COIN_HEIGHT);
    
}

@end
