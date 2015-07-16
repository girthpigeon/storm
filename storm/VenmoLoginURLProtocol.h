//
//  VenmoLoginURLProtocol.h
//  storm
//
//  Created by Zack Pajka on 7/13/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VenmoLoginURLProtocol : NSURLProtocol <NSURLConnectionDelegate>
@property (nonatomic, strong) NSURLConnection *m_connection;
@property (nonatomic, strong) NSMutableData *m_responseData;

@end
