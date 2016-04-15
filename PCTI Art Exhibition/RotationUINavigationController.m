//
//  RotationUINavigationController.m
//  PCTI Art Exhibition
//
//  Created by Dan on 3/8/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "RotationUINavigationController.h"

@implementation RotationUINavigationController

- (BOOL)shouldAutorotate {
    // Normal behavior
    if (self.topViewController != nil) {
        return [self.topViewController shouldAutorotate];
    } else {
        return [super shouldAutorotate];
    }
    
    // Authoritarian government DENIES ALL ROTATION.
    // return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // Normal behavior
    /*if (self.topViewController != nil) {
        return [self.topViewController supportedInterfaceOrientations];
    } else {
        return [super supportedInterfaceOrientations];
    }*/

    // We're supporting portrait and upside down.
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    // Normal behavior
    /*if (self.topViewController != nil) {
        return [self.topViewController preferredInterfaceOrientationForPresentation];
    } else {
        return [super preferredInterfaceOrientationForPresentation];
    }*/
    
    // And we *prefer* portrait.
    return UIInterfaceOrientationPortrait;
}

@end
