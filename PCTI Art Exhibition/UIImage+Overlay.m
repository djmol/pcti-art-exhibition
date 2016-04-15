//
//  UIImage+Overlay.m
//  PCTI Art Exhibition
//
//  Created by Dan on 3/15/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "UIImage+Overlay.h"

@implementation UIImage (Overlay)

// Thanks to http://stackoverflow.com/a/24106632 !
- (UIImage *)imageWithColor:(UIColor *)color1 {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color1 setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
