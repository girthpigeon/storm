//
//  StormHistoryViewController.m
//  storm
//
//  Created by Zack Pajka on 2/16/16.
//  Copyright © 2016 Swerve. All rights reserved.
//

#import "StormHistoryViewController.h"
#import "StormCell.h"
#import "Storm.h"
#import "Utils.h"
#import "Singleton.h"

@interface StormHistoryViewController ()

@end

@implementation StormHistoryViewController

@synthesize m_stormsArray;
@synthesize m_stormHistoryTable;
@synthesize height;
@synthesize width;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    width = screenRect.size.width;
    height = screenRect.size.height;
    
    [self setupTableView];
    [self retrievePastStorms];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupTableView
{
    m_stormHistoryTable = [[UITableView alloc] init];
    m_stormHistoryTable.frame = CGRectMake(0, height, width, height);
    m_stormHistoryTable.dataSource=self;
    m_stormHistoryTable.delegate=self;
    m_stormHistoryTable.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [m_stormHistoryTable reloadData];
    [self.view addSubview:m_stormHistoryTable];
}

- (void) retrievePastStorms
{
    
    // send a coin with coinValue to server
    Singleton* appData = [Singleton sharedInstance];
    NSString *urlString = [NSString stringWithFormat:@"%@api/storms/?", appData.serverUrl];
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
        
        if (responseString != nil)
        {
            NSMutableArray *storms = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            for (NSArray *storm in storms)
            {
                NSString *stormId = [storm valueForKey:@"id"];
                NSString *message = [storm valueForKey:@"message"];
                NSString *fullName = [storm valueForKey:@"displayName"];
                NSString *profUrl = [storm valueForKey:@"senderProfUrl"];
                
                Storm *currentStorm = [[Storm alloc] initHistoryStorm:fullName withStormId:stormId withMessage:message withProf:profUrl];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getCollectedStatus:currentStorm];
                });
                
            }
        }
        
    }] resume];

}

- (void) getCollectedStatus:(Storm *)storm
{
    // send a coin with coinValue to server
    Singleton* appData = [Singleton sharedInstance];
    NSString *urlString = [NSString stringWithFormat:@"%@api/storms/collectionStatus?", appData.serverUrl];
    NSString *postString = [NSString stringWithFormat:@"stormId=%@&", appData.userId];
    
    NSString *fullString = [NSString stringWithFormat:@"%@%@",urlString, postString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setValue:appData.token forHTTPHeaderField:@"X-Auth-Token"];
    
    [request setURL:[NSURL URLWithString:fullString]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", responseString);
        
        if (responseString != nil)
        {
            NSMutableArray *storms = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            for (NSArray *data in storms)
            {
                NSString *stormId = [data valueForKey:@"id"];
                NSString *moneyCollected = [data valueForKey:@"coinsCollected"];
                NSString *moneySent = [data valueForKey:@"coinsSent"];
                
                NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
                [doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
                [doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:2];
                NSNumber *collectedValue = [doubleValueWithMaxTwoDecimalPlaces numberFromString:moneyCollected];
                NSNumber *sentValue = [doubleValueWithMaxTwoDecimalPlaces numberFromString:moneySent];
                
                [storm setMoneyRedeemed:[collectedValue stringValue] withMoneySent: [sentValue stringValue]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [m_stormsArray addObject:storm];
                    [m_stormHistoryTable reloadData];
                });
                
            }
        }
        
    }] resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_stormsArray.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StormCell";
    StormCell *cell = (StormCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StormCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Storm* storm =[m_stormsArray objectAtIndex:indexPath.row];
    cell.m_fromUser.text = storm.SenderFullName;
    cell.m_stormMessageLabel.text = storm.Message;
    //cell.m_totalAmount = [NSString stringWithFormat:@"$%d accpeted", storm.];
    [Utils circlize:storm.SenderProf withImageView:cell.m_thumbnailImageView];
    
    cell.m_thumbnailImageView.image = storm.SenderProf;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     //=[m_stormsArray objectAtIndex:indexPath.row];
    //[self changeRecipient];
    //[self dismissFriendsPicker];
}


@end
