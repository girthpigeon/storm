//
//  ViewController.m
//  storm
//
//  Created by Zack Pajka on 6/7/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "HomeScreenViewController.h"
#import "KeychainItemWrapper.h"

@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"userId" accessGroup:nil];
    //[keychain resetKeychainItem];
    NSString *userId = [keychain objectForKey:(__bridge id)(kSecAttrAccount)];
    
    if ([userId isEqualToString:@""])
    {
        [self performSegueWithIdentifier:@"VenmoAuthSegue" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
