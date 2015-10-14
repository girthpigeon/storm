//
//  Utils.m
//  storm
//
//  Created by Zack Pajka on 10/5/15.
//  Copyright (c) 2015 Swerve. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (void)circlize:(UIImage *)image withImageView:(UIImageView*)imageView
{
    imageView.image = image;
    imageView.layer.cornerRadius = imageView.frame.size.height /2;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 0;
    
    return;
}

+ (NSString*) encrypt:(NSString*)unencryptedString withPassword:(NSString*)password
{
    NSData *data = [unencryptedString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                            password:password
                                               error:&error];
    NSString* encryptedString = [NSString stringWithUTF8String:[encryptedData bytes]];
    return encryptedString;
}

+ (NSString*) decrypt:(NSString*)encryptedData withPassword:(NSString *)password
{
    NSData *data = [encryptedData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *decryptedData = [RNDecryptor decryptData:data
                                        withPassword:password
                                               error:&error];
    NSString* decryptedString = [NSString stringWithUTF8String:[decryptedData bytes]];
    return decryptedString;
}


@end
