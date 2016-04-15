//
//  ArtworkViewController.h
//  PCTI Art Exhibition
//
//  Created by Dan on 1/6/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "ArtSite.h"
#import <UIKit/UIKit.h>

@interface ArtworkViewController : UIViewController <UIActivityItemSource, UIScrollViewDelegate>

- (void)setViewColorScheme;
@property (nonatomic, weak) IBOutlet UIImageView *artImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *artImageScrollView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextView *bioTextView;
@property (nonatomic, weak) IBOutlet UILabel *mediumLabel;
@property (nonatomic, weak) IBOutlet UIImageView *headshotImageView;
@property (nonatomic, weak) IBOutlet UIImageView *bannerImageView;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *actionButton;
@property (nonatomic, strong) ArtSite *artSite;
@property (nonatomic, strong) NSMutableArray *colorScheme;
@property (nonatomic, strong) UIColor *schemeColor;
@property (nonatomic, strong) UIColor *contrastColor;
@property (nonatomic, strong) UIColor *unselectedColor;
@property (nonatomic, strong) UIColor *unselectedOpaqueColor;

@end
