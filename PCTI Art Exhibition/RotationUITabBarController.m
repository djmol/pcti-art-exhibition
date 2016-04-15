//
//  RotationUITabBarController.m
//  PCTI Art Exhibition
//
//  Created by Dan on 3/8/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "RotationUITabBarController.h"
#import "UIImage+Overlay.h"

@interface RotationUITabBarController ()

@end

@implementation RotationUITabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Adapted from http://stackoverflow.com/a/24106632
    [self setTabBarItemColorsWithSelectedColor:[UIColor whiteColor] unselectedColor:[UIColor whiteColor]];
}

- (void)setTabBarItemColorsWithSelectedColor:(UIColor *)selectedColor unselectedColor:(UIColor *)unselectedColor {
    // Set tab bar item selected colors
    [self.tabBar setTintColor:selectedColor];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: selectedColor, NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    // Set color of unselected text
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:unselectedColor, NSForegroundColorAttributeName, nil]
                                             forState:UIControlStateNormal];
    
    // Generate a tinted unselected image based on image passed via the storyboard
    for(UITabBarItem *item in self.tabBar.items) {
        // use the UIImage category code for the imageWithColor: method
        item.image = [[item.image imageWithColor:unselectedColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

- (BOOL)shouldAutorotate {
    // Normal behavior
    return [super shouldAutorotate];
    
    // NO ROTATION NOT EVER
    //return NO;
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
