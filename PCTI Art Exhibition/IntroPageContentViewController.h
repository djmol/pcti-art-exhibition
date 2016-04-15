//
//  IntroPageContentViewController.h
//  PCTI Art Exhibition
//
//  Created by Dan on 3/2/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IntroPageContentViewController;

@protocol IntroPageContentViewControllerDelegate <NSObject>

- (void)continueButtonTouched;

@end

@interface IntroPageContentViewController : UIViewController

- (void)transitionContinueButton;
@property NSUInteger pageIndex;
@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *imageFile;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *pageImageView;
@property (nonatomic, weak) IBOutlet UIButton *continueButton;
@property (nonatomic, weak) id <IntroPageContentViewControllerDelegate> delegate;

@end
