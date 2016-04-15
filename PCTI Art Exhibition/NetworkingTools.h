//
//  NetworkingTools.h
//  PCTI Art Exhibition
//
//  Created by Dan on 1/12/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NetworkingTools : NSObject

+ (void)downloadImageFromURL:(NSURL *)imageURL toView:(UIImageView *)imageView withProgress:(UIProgressView *)progressView;
+ (void)downloadImageFromURL:(NSURL *)imageURL toView:(UIImageView *)imageView withActivity:(UIActivityIndicatorView *)activityIndicator;
+ (void)downloadPlistFromURL:(NSURL *)fileURL notifyAt:(NSString *)notificationName;

@end
