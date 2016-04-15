//
//  IntroViewController.h
//  PCTI Art Exhibition
//
//  Created by Dan on 3/2/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntroPageViewController.h"
#import "IntroPageContentViewController.h"

@interface IntroViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, IntroPageContentViewControllerDelegate>

@property (nonatomic, strong) IntroPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *pageTitles;
@property (nonatomic, strong) NSArray *imageFiles;
@property (nonatomic, strong) NSArray *backgroundColors;

@end
