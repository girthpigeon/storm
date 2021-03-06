//
//  ViewController.m
//  storm
//
//  Created by Zack Pajka on 6/7/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "KeychainItemWrapper.h"
#import "Singleton.h"
#import "DBManager.h"

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController

bool m_loaded;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!m_loaded)
    {
        [self setupView];
        m_loaded = true;
    }
    
    // authenticate user and save to singleton NEW
    // curl -X POST --header "Content-Type: application/json"  "http://storm-of-coins.herokuapp.com/api/authenticate?username=admin&password=admin"
}

-(void) setupView
{
    [self setupButtons];
    
    KeychainItemWrapper *userKey = [[KeychainItemWrapper alloc] initWithIdentifier:@"username" accessGroup:nil];
    KeychainItemWrapper *passKey = [[KeychainItemWrapper alloc] initWithIdentifier:@"password" accessGroup:nil];
    //[userKey resetKeychainItem];
    //[passKey resetKeychainItem];
    NSString *username = [userKey objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *password = [passKey objectForKey:(__bridge id)(kSecAttrAccount)];
    
    if (username == nil || [username isEqualToString:@""])
    {
        [self performSegueWithIdentifier:@"VenmoAuthSegue" sender:self];
    }
    else
    {
        Singleton* appData = [Singleton sharedInstance];
        appData.userId = username;
        appData.password = password;
        
        //[DBManager authenticate];
    }
}

-(void)setupButtons
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float width = screenRect.size.width;
    float height = screenRect.size.height;
    
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = height / 10;
    frame.size.width = width;
    frame.size.height = height / 4;
    self.m_makeItRain.frame = frame;
    
    UIButton *makeItRainButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    makeItRainButton.frame = frame;
    [makeItRainButton setTitle:@"Make It Rain" forState:UIControlStateNormal];
    makeItRainButton.backgroundColor = [UIColor clearColor];
    [makeItRainButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    UIImage *buttonImageNormal = [UIImage imageNamed:@"MainCloud.png"];
    [makeItRainButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];

    [makeItRainButton addTarget:self action:@selector(makeItRain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:makeItRainButton];
    
    frame.origin.y = 4 * (height / 10);
    self.m_cashCloud.frame = frame;
    
    UIButton *cashCloudButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cashCloudButton.frame = frame;
    [cashCloudButton setTitle:@"Cash Cloud" forState:UIControlStateNormal];
    cashCloudButton.backgroundColor = [UIColor clearColor];
    [cashCloudButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [cashCloudButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
    
    [cashCloudButton addTarget:self action:@selector(cashCloud:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cashCloudButton];
    
    frame.origin.y = 7 * (height / 10);
    self.m_settings.frame = frame;
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    settingsButton.frame = frame;
    [settingsButton setTitle:@"Log in with Venmo" forState:UIControlStateNormal];
    settingsButton.backgroundColor = [UIColor clearColor];
    [settingsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal ];
    [settingsButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
    
    [settingsButton addTarget:self action:@selector(settings:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingsButton];

}

-(void) makeItRain:(UIButton*)sender
{
    [self performSegueWithIdentifier:@"MakeItRainSegue" sender:self];
}

-(void) cashCloud:(UIButton*)sender
{
    [self performSegueWithIdentifier:@"CashCloudSegue" sender:self];
}

-(void) settings:(UIButton*)sender
{
    [self performSegueWithIdentifier:@"VenmoAuthSegue" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
