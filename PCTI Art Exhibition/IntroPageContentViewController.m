//
//  IntroPageContentViewController.m
//  PCTI Art Exhibition
//
//  Created by Dan on 3/2/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "IntroPageContentViewController.h"
#import "IntroPageViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import <QuartzCore/QuartzCore.h>

@implementation IntroPageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.titleText;

    // Set page image based on screen width
    //NSNumber *screenWidth = @([UIScreen mainScreen].bounds.size.width);
    NSString *imageName = self.imageFile;
    
    // This was used to set different images for different screen sizes
    /*if ([screenWidth intValue] == 320) {
        NSNumber *screenHeight = @([UIScreen mainScreen].bounds.size.height);
        if ([screenHeight intValue] == 480) {
            imageName = [NSString stringWithFormat:@"%@-%@w4", self.imageFile, screenWidth];
        } else {
            imageName = [NSString stringWithFormat:@"%@-%@w5", self.imageFile, screenWidth];
        }
    } else {
        imageName = [NSString stringWithFormat:@"%@-%@w", self.imageFile, screenWidth];
    }*/
    
    UIImage *image = [UIImage imageNamed:imageName];
    [self.pageImageView setImage:image];

    // Add action to continue button or remove button entirely
    if (self.delegate && [self.delegate respondsToSelector:@selector(continueButtonTouched)]) {
        // Set default Continue button appearance (for "Start Location Services")
        //self.continueButton.backgroundColor = [UIColor whiteColor];
        [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.continueButton.layer.cornerRadius = 10; // this value vary as per your desire
        self.continueButton.clipsToBounds = YES;
        
        [self.continueButton addTarget:self.delegate action:@selector(continueButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [self.continueButton setTitle:NSLocalizedString(@"INTRO_START_LOCATION_SERVICES_BUTTON", nil) forState:UIControlStateNormal];
        
        // If we're re-running the intro, skip the "Start Location Services" phase of the continue button
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenIntro"]) {
            [self transitionContinueButton];
        }
    } else {
        [self setButton:self.continueButton titleText:@""];
        //[self.continueButton removeFromSuperview];
    }
}

- (void)transitionContinueButton {
    //self.continueButton.backgroundColor = [UIColor whiteColor];
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setButton:self.continueButton titleText:NSLocalizedString(@"INTRO_CONTINUE_BUTTON", nil)];
}

- (void)setButton:(UIButton *)button titleText:(NSString *)text {
    // This is a lame solution but I don't want to risk breaking things or wasting time making a category for UIButton.
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateApplication];
    [button setTitle:text forState:UIControlStateHighlighted];
    [button setTitle:text forState:UIControlStateSelected];
    [button setTitle:text forState:UIControlStateReserved];
    [button setTitle:text forState:UIControlStateDisabled];
}
@end
