//
//  IntroViewController.m
//  PCTI Art Exhibition
//
//  Created by Dan on 3/2/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "AppDelegate.h"
#import "BeaconMenuViewController.h"
#import "IntroPageContentViewController.h"
#import "IntroViewController.h"
#import "RotationUITabBarController.h"
#import <ChameleonFramework/Chameleon.h>

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@interface IntroViewController()

@property int wobbleAnimationCount;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create our page data
    self.pageTitles = @[NSLocalizedString(@"INTRO_PAGE_1", nil),
                        NSLocalizedString(@"INTRO_PAGE_2", nil),
                        NSLocalizedString(@"INTRO_PAGE_3", nil),
                        NSLocalizedString(@"INTRO_PAGE_4", nil),];
    self.imageFiles = @[@"pcvc",@"pcvc",@"pcvc",@"pcvc"];
    self.backgroundColors = @[[UIColor colorWithHexString:@"2799D5"],
                              [UIColor colorWithHexString:@"8BC53F"],
                              [UIColor colorWithHexString:@"F6921E"],
                              [UIColor colorWithHexString:@"BE1E2D"]];
    
    // Create our page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroPage"];
    self.pageViewController.dataSource = self;
    IntroPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    // Add page view controller
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    // Set page view controller Delegate
    self.pageViewController.delegate = self;
    
    // Set initial background color
    self.view.backgroundColor = self.backgroundColors[0];
    
    // Set wobble animation count
    self.wobbleAnimationCount = 0;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [((IntroPageContentViewController *) viewController) pageIndex];
    
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [((IntroPageContentViewController *) viewController) pageIndex];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    return [self viewControllerAtIndex:index];
}

- (IntroPageContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    IntroPageContentViewController *introPageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroPageContent"];
    introPageContentViewController.titleText = self.pageTitles[index];
    introPageContentViewController.imageFile = self.imageFiles[index];
    introPageContentViewController.backgroundColor = self.backgroundColors[index];
    introPageContentViewController.pageIndex = index;
    
    // Set page view content view controller delegate (that's a mouthful) on the last view controller
    if (index == [self.pageTitles count] - 1) {
        introPageContentViewController.delegate = self;
    }
    
    return introPageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    // Perform page-specific UI updates here
    if ([pendingViewControllers count] > 0) {
        NSUInteger index = [(IntroPageContentViewController *)[pendingViewControllers objectAtIndex:0] pageIndex];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.backgroundColor = self.backgroundColors[index];
        }];
    }
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    // If transition to next page does not complete (like, if you just nudge the page one direction a little), change the background color back to what it was
    if (!completed) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.backgroundColor = [(IntroPageContentViewController *)[previousViewControllers firstObject] backgroundColor];
        }];
    }
}

#pragma mark - Intro Page Content View Controller Delegate

- (void)continueButtonTouched {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenIntro"]) {
        // Request location services
        RotationUITabBarController *tabBarController = (RotationUITabBarController *)self.presentingViewController;
        UINavigationController *navigationController = tabBarController.viewControllers[0];
        BeaconMenuViewController *beaconMenuViewController = navigationController.viewControllers[0];
        [beaconMenuViewController.beaconManager requestWhenInUseAuthorization];
        
        // Update button text
        IntroPageContentViewController *pageContentViewController = (IntroPageContentViewController *)self.pageViewController.viewControllers[0];
        [UIView transitionWithView:pageContentViewController.continueButton
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [pageContentViewController transitionContinueButton];
                        }
                        completion:^(BOOL finished){
                            // Wobble the Continue button after transitioning.
                            [self performSelector:@selector(startWobble:) withObject:pageContentViewController.continueButton afterDelay:1.0];
                        }];
        
        // Disable presenting introduction on future launches
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenIntro"];
    } else {
        // Dismiss intro and transition to beacon menu
        [UIView transitionWithView:self.view.window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self dismissViewControllerAnimated:FALSE completion:nil];
                        }
                        completion:nil];
    }
}

#pragma mark - Animation

// Adapted from http://stackoverflow.com/a/5722296
// (Because animation is math and difficult.)

- (void)startWobble:(UIButton *)itemView {
    itemView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-5));
    
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                     animations:^ {
                         itemView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(5));
                         // The wobbling will continue until we call stopWobble, so this calls it after a few wobbles.
                         [self performSelector:@selector(stopWobble:) withObject:itemView afterDelay:1.0];
                     }
                     completion:NULL
     ];
}

- (void)stopWobble:(UIButton *)itemView {
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear)
                     animations:^ {
                         itemView.transform = CGAffineTransformIdentity;
                         // Auto-starts the wobble back up after a delay. (So, yes, the wobbling loops on and off indefinitely.)
                         [self performSelector:@selector(startWobble:) withObject:itemView afterDelay:2.0];
                     }
                     completion:NULL
     ];
}

#pragma mark - Orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return (UIInterfaceOrientationMaskPortrait);
}

@end
