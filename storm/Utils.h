//
//  Utils.h
//  storm
//
//  Created by Zack Pajka on 10/5/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

//! Project version number for RNCryptor iOS.
//FOUNDATION_EXPORT double RNCryptor_iOSVersionNumber;

//! Project version string for RNCryptor iOS.
//FOUNDATION_EXPORT const unsigned char RNCryptor_iOSVersionString[];

#import "RNCryptor/RNCryptor.h"
#import "RNCryptor/RNDecryptor.h"
#import "RNCryptor/RNEncryptor.h"
#import "RNCryptor/RNCryptorEngine.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

+ (void)circlize:(UIImage *)image withImageView:(UIImageView*)imageView;
+ (NSString*)encrypt:(NSString*)unencryptedString withPassword:(NSString*)password;
+ (NSString*)decrypt:(NSString*)encryptedData withPassword:(NSString*)password;

@end
