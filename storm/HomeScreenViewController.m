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

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    KeychainItemWrapper *userKey = [[KeychainItemWrapper alloc] initWithIdentifier:@"userId" accessGroup:nil];
    KeychainItemWrapper *stormKey = [[KeychainItemWrapper alloc] initWithIdentifier:@"userId" accessGroup:nil];
    //[keychain resetKeychainItem];
    NSString *userId = [userKey objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *stormId = [stormKey objectForKey:(__bridge id)(kSecAttrAccount)];
    
    if ([userId isEqualToString:@""])
    {
        //[self performSegueWithIdentifier:@"VenmoAuthSegue" sender:self];
    }
    else
    {
        Singleton* appData = [Singleton sharedInstance];
        appData.userId = userId;
        appData.stormId = stormId;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end