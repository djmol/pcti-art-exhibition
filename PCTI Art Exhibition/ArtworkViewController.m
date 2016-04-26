//
//  ArtworkViewController.m
//  PCTI Art Exhibition
//
//  Created by Dan on 1/6/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "AppDelegate.h"
#import "ArtworkViewController.h"
//#import "NetworkingTools.h"
#import "RotationUITabBarController.h"
#import "UIImage+ColorArt.h"
//#import <PINRemoteImage/PINRemoteImage.h>
//#import <PINRemoteImage/UIImageView+PINRemoteImage.h>
//#import <PINCache/PINCache.h>
#import <ChameleonFramework/Chameleon.h>

// Used in Custom Animation (Navigation Bar Color)
#define STEP_DURATION 0.001

@interface ArtworkViewController ()

//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bioTextViewHeightConstraint;
@property (nonatomic) BOOL initialLoad;

@end

@implementation ArtworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set navigation bar title
    self.navigationItem.title = [self.artSite.siteInfo valueForKey:[@(ArtSiteTitle) stringValue]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    // No download version!
    // Set site data
    if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkViewMode) stringValue]] isEqualToString:@"Fill"]) {
        self.artImageView.contentMode = UIViewContentModeScaleAspectFill; //hey.... work
        [self.artImageView sizeToFit];
    } else if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkViewMode) stringValue]] isEqualToString:@"Fit"]) {
        self.artImageView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.artImageView.contentMode = UIViewContentModeScaleAspectFit;
    }

    // Set up artImageScrollView
    UIImage *artImage = [UIImage imageNamed:[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkImage) stringValue]]];
    self.artImageScrollView.maximumZoomScale = 5.0;
    self.artImageScrollView.minimumZoomScale = 1.0;
    self.artImageScrollView.delegate = self;
    self.artImageView.image = artImage;
    
    self.titleLabel.text = [self.artSite.siteInfo valueForKey:[@(ArtSiteTitle) stringValue]];
    self.bioTextView.text = [self.artSite.siteInfo valueForKey:[@(ArtSiteBio) stringValue]];
    self.mediumLabel.text = [self.artSite.siteInfo valueForKey:[@(ArtSiteMedium) stringValue]];
    self.artistLabel.text = [self.artSite.siteInfo valueForKey:[@(ArtSiteArtist) stringValue]];
    self.headshotImageView.image = [UIImage imageNamed:[self.artSite.siteInfo valueForKey:[@(ArtSiteHeadshotImage) stringValue]]];
    self.bannerImageView.image = [UIImage imageNamed:[self.artSite.siteInfo valueForKey:[@(ArtSiteBannerImage) stringValue]]];
    
    // Set bioTextView content size
    self.bioTextView.contentSize = CGSizeMake(self.bioTextView.frame.size.width, self.bioTextView.frame.size.height);
    [self.bioTextView setContentOffset:CGPointMake(0,-500) animated:YES];
    //[self.bioTextView sizeToFit];
    
    // Set navigation bar and tab bar color
    // Determine and set color scheme colors
    [self setViewColorScheme];
    
    // (Some unused functions that might be useful one day...)
    // Get contrast color (either black or white) based on our scheme color
    /*self.contrastColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.schemeColor isFlat:FALSE alpha:1.0]; // Their macro for this is broken, I think.
    
    // Ensure that the contrast color will always be white by gradually darkening the scheme color
    UIColor *blackColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:[UIColor whiteColor] isFlat:FALSE alpha:1.0];
    while ([self.contrastColor isEqual:blackColor]) {
        self.schemeColor = [self.schemeColor darkenByPercentage:.01];
        self.contrastColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.schemeColor isFlat:FALSE alpha:1.0];
    }
    
    // Set unselected item contrast colors
    self.unselectedColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.schemeColor isFlat:FALSE alpha:1.0];
    self.unselectedOpaqueColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.schemeColor isFlat:FALSE alpha:1.0];*/
    
    // We have to use a custom animation to fade the navigation/status bar color because Apple Is Dumb
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[self animateNavigationBarFromColor:appDelegate.mainColor toColor:self.schemeColor duration:0.3];
    //[self animateNavigationTintFromColor:appDelegate.mainColor toColor:self.contrastColor duration:0.3];
    /*self.navigationController.navigationBar.barTintColor = self.schemeColor;
    self.navigationController.navigationBar.tintColor = self.contrastColor;
    
    // We can do the tab bar animation juuuust fine, though
    [UIView transitionWithView:self.navigationController.tabBarController.tabBar
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        //NSArray *colorArray = ColorsFromImage(self.artImageView.image, TRUE);
                        self.tabBarController.tabBar.barTintColor = self.schemeColor;
                        RotationUITabBarController *tabBarController = (RotationUITabBarController *)self.tabBarController;
                        [tabBarController setTabBarItemColorsWithSelectedColor:self.contrastColor unselectedColor:self.unselectedColor];
                        //self.tabBarController.tabBar.tintColor = self.contrastColor;
                    }
                    completion:nil];
    NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
    for (UITabBarItem *item in self.tabBarController.tabBar.items) {
        [tabBarItems addObject:item];
    }*/
    
    
    
    // (Download version)
    // Get image URL
    /*NSDictionary *resourceDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:@"Resources" ofType:@"plist"]];
    NSMutableString *imageURLString = [[NSMutableString alloc] initWithString:[resourceDict valueForKey:@"URLPrefix"]];
    [imageURLString appendString:[self.siteInfo valueForKey:@"Image"]];
    NSURL *imageURL = [NSURL URLWithString:imageURLString];*/
    
    // Download assets
    // PINRemoteImage method (omfg so good)
    /*[self.artImageView pin_setImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
    [self.artImageView pin_setImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder"] completion:^void (PINRemoteImageManagerResult *result) {
        // Set navigation bar and tab bar color
        // Get color scheme colors
        self.colorScheme = ColorsFromImage(self.artImageView.image, TRUE);
        self.schemeColor = self.colorScheme[0];
        self.contrastColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.schemeColor isFlat:FALSE alpha:1.0]; // Their macro for this is broken, I think.
        self.unselectedColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.schemeColor isFlat:FALSE alpha:1.0];
        self.unselectedOpaqueColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.schemeColor isFlat:FALSE alpha:1.0];
        
         // We have to use a custom animation to fade the navigation/status bar color because Apple Is Dumb
         AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
         [self animateNavigationBarFromColor:appDelegate.mainColor toColor:self.schemeColor duration:0.3];
         [self animateNavigationTintFromColor:appDelegate.mainColor toColor:self.contrastColor duration:0.3];
     
        // We can do the tab bar animation juuuust fine, though
        [UIView transitionWithView:self.navigationController.tabBarController.tabBar
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            //NSArray *colorArray = ColorsFromImage(self.artImageView.image, TRUE);
                            self.tabBarController.tabBar.barTintColor = self.schemeColor;
                            RotationUITabBarController *tabBarController = (RotationUITabBarController *)self.tabBarController;
                            [tabBarController setTabBarItemColorsWithSelectedColor:self.contrastColor unselectedColor:self.unselectedColor];
                            //self.tabBarController.tabBar.tintColor = self.contrastColor;
                        }
                        completion:nil];
        NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
        for (UITabBarItem *item in self.tabBarController.tabBar.items) {
            [tabBarItems addObject:item];
        }
    }];*/
    
    // AFNetworking method (with progress bar, which I deleted)
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [NetworkingTools downloadImageFromURL:imageURL toView:self.artImageView withProgress:self.progressView];
    });*/
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Set colors with transition
        self.navigationController.navigationBar.barTintColor = self.schemeColor;
        self.navigationController.navigationBar.tintColor = self.contrastColor;
        self.tabBarController.tabBar.barTintColor = self.schemeColor;
        self.tabBarController.tabBar.tintColor = self.contrastColor;
    } completion:nil];

    // Set selected tab bar item text color (doing this in transition gives a dumb "HERE I AM" animation to the entire item)
    [[self.tabBarController.tabBar.items objectAtIndex:0] // Note that this index is hard-coded. It's not ideal, but there are more pressing issues atm.
     setTitleTextAttributes:@{ NSForegroundColorAttributeName : self.contrastColor } forState:UIControlStateSelected];
    
    // Set colors if we're not using a transition
    if (![self transitionCoordinator]) {
        self.navigationController.navigationBar.barTintColor = self.schemeColor;
        self.navigationController.navigationBar.tintColor = self.contrastColor;
        self.tabBarController.tabBar.barTintColor = self.schemeColor;
        self.tabBarController.tabBar.tintColor = self.contrastColor;
    }
    
    // Format BioTextView
    self.bioTextView.textContainer.lineFragmentPadding = 0;
    self.bioTextView.textContainerInset = UIEdgeInsetsZero;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // Set the height of our artImageScrollView
    // (AutoLayout is a huge painus in my ainus, so manually doing it here is easier, even if it incurs magic numbers.)
    // Landscape values were calculated, portrait values were eyeballed
    CGFloat deviceHeight = [[UIScreen mainScreen] bounds].size.height;
    if (deviceHeight == 1366) {
        // iPad Pro
        if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkViewMode) stringValue]] isEqualToString:@"Fill"]) {
            // Landscape
            self.artImageScrollViewHeight.constant = 662;
        } else if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkViewMode) stringValue]] isEqualToString:@"Fit"]) {
            // Portrait
            self.artImageScrollViewHeight.constant = 880;
        }
    } else if (deviceHeight == 1024) {
        // iPad
        if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkViewMode) stringValue]] isEqualToString:@"Fill"]) {
            // Landscape
            self.artImageScrollViewHeight.constant = 497;
        } else if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkViewMode) stringValue]] isEqualToString:@"Fit"]) {
            // Portrait
            self.artImageScrollViewHeight.constant = 538;
        }
    } else if (deviceHeight == 736) {
        // iPhone 6+
        if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkViewMode) stringValue]] isEqualToString:@"Fill"]) {
            // Landscape
            self.artImageScrollViewHeight.constant = 268;
        } else if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkViewMode) stringValue]] isEqualToString:@"Fit"]) {
            // Portrait
            self.artImageScrollViewHeight.constant = 350;
        }
    } else if (deviceHeight == 667) {
        // iPhone 6
        if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkViewMode) stringValue]] isEqualToString:@"Fill"]) {
            // Landscape
            self.artImageScrollViewHeight.constant = 243;
        } else if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkViewMode) stringValue]] isEqualToString:@"Fit"]) {
            // Portrait
            self.artImageScrollViewHeight.constant = 300;
        }
    } else if (deviceHeight == 568 || deviceHeight == 480) {
        // iPhone 5S-4S
        if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkViewMode) stringValue]] isEqualToString:@"Fill"]) {
            // Landscape
            self.artImageScrollViewHeight.constant = 207;
        } else if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkViewMode) stringValue]] isEqualToString:@"Fit"]) {
            // Portrait
            self.artImageScrollViewHeight.constant = 250;
        }
    }
    
    // Set the content size so we can scroll and zoom on the image properly
    self.artImageScrollView.contentSize = self.artImageView.frame.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIActivityViewController

- (IBAction)actionButtonTouched:(id)sender {
    NSArray *activityItems = @[self.artImageView.image, @"#PCTIArtShow2016"];
    // Return @[self] to customize return value for each activity
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    // Set activityViewController anchor for iOS8+
    if ( [activityViewController respondsToSelector:@selector(popoverPresentationController)] ) {
        activityViewController.popoverPresentationController.barButtonItem = self.actionButton;
    }

    [self presentViewController:activityViewController animated:TRUE completion:nil];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    // Determine what to return -- but note that you can't return an array! So... how to return both image and text?
    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        return self.artImageView.image;
    } else if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return self.artImageView.image;
    } else {
        return nil;
    }
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    // We might want to implement this we're doing custom return values for activities
    return self.artImageView.image;
}


- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    // And we might also want to implement this we're doing custom return values for activities
    NSString *string;
    return string;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController dataTypeIdentifierForActivityType:(NSString *)activityType{
    // Aaand we might also want to implement this we're doing custom return values for activities
    NSString *string;
    return string;
}

- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(NSString *)activityType suggestedSize:(CGSize)size {
    // Aaaaaand we might also want to implement this we're doing custom return values for activities.
    UIImage *image;
    return image;
}

# pragma mark - Custom Animation (Navigation Bar Color)

// Thanks to http://stackoverflow.com/questions/20377628/transition-color/20396308?noredirect=1#20396308 !

- (void)animateNavigationBarFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor duration:(NSTimeInterval)duration
{
    NSUInteger steps = duration / STEP_DURATION;
    
    CGFloat fromRed;
    CGFloat fromGreen;
    CGFloat fromBlue;
    CGFloat fromAlpha;
    
    [fromColor getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed;
    CGFloat toGreen;
    CGFloat toBlue;
    CGFloat toAlpha;
    
    [toColor getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat diffRed = toRed - fromRed;
    CGFloat diffGreen = toGreen - fromGreen;
    CGFloat diffBlue = toBlue - fromBlue;
    CGFloat diffAlpha = toAlpha - fromAlpha;
    
    NSMutableArray *colorArray = [NSMutableArray array];
    
    [colorArray addObject:fromColor];
    
    for (NSUInteger i = 0; i < steps - 1; ++i) {
        CGFloat red = fromRed + diffRed / steps * (i + 1);
        CGFloat green = fromGreen + diffGreen / steps * (i + 1);
        CGFloat blue = fromBlue + diffBlue / steps * (i + 1);
        CGFloat alpha = fromAlpha + diffAlpha / steps * (i + 1);
        
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [colorArray addObject:color];
    }
    
    [colorArray addObject:toColor];
    
    [self animateNavigationBarColorWithArray:colorArray];
}

- (void)animateNavigationBarColorWithArray:(NSMutableArray *)array
{
    NSUInteger counter = 0;
    
    for (UIColor *color in array) {
        double delayInSeconds = STEP_DURATION * counter++;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:STEP_DURATION animations:^{
                self.navigationController.navigationBar.barTintColor = color;
            }];
        });
    }
}

- (void)animateNavigationTintFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor duration:(NSTimeInterval)duration
{
    NSUInteger steps = duration / STEP_DURATION;
    
    CGFloat fromRed;
    CGFloat fromGreen;
    CGFloat fromBlue;
    CGFloat fromAlpha;
    
    [fromColor getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed;
    CGFloat toGreen;
    CGFloat toBlue;
    CGFloat toAlpha;
    
    [toColor getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat diffRed = toRed - fromRed;
    CGFloat diffGreen = toGreen - fromGreen;
    CGFloat diffBlue = toBlue - fromBlue;
    CGFloat diffAlpha = toAlpha - fromAlpha;
    
    NSMutableArray *colorArray = [NSMutableArray array];
    
    [colorArray addObject:fromColor];
    
    for (NSUInteger i = 0; i < steps - 1; ++i) {
        CGFloat red = fromRed + diffRed / steps * (i + 1);
        CGFloat green = fromGreen + diffGreen / steps * (i + 1);
        CGFloat blue = fromBlue + diffBlue / steps * (i + 1);
        CGFloat alpha = fromAlpha + diffAlpha / steps * (i + 1);
        
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [colorArray addObject:color];
    }
    
    [colorArray addObject:toColor];
    
    [self animateNavigationTintColorWithArray:colorArray];
}

- (void)animateNavigationTintColorWithArray:(NSMutableArray *)array {
    NSUInteger counter = 0;
    
    for (UIColor *color in array) {
        double delayInSeconds = STEP_DURATION * counter++;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:STEP_DURATION animations:^{
                self.navigationController.navigationBar.tintColor = color;
            }];
        });
    }
}

#pragma mark - Appearance/UI

- (void)setViewColorScheme {
    // This is used to set up the color scheme in case viewWillAppear isn't called before appearing, like when we're using peek/pop
    
    // Not sure why we don't have to set this here...
    //[[self.tabBarController.tabBar.items objectAtIndex:0] // Note that this index is hard-coded. It's not ideal, but there are more pressing issues atm.
    // setTitleTextAttributes:@{ NSForegroundColorAttributeName : self.contrastColor } forState:UIControlStateSelected];
    
    // Set colors if we're not using a transition
    /*self.colorScheme = [[NSMutableArray alloc] initWithArray: ColorsFromImage([UIImage imageNamed:[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkImage) stringValue]]], FALSE)];
    
    // Get the most colorful color in the color scheme! (This is optional and kind of silly but WHATEVER.)
    self.schemeColor = [self mostColorfulInScheme:self.colorScheme];
    
    // Get secondary scheme color
    UIColor *secondaryColor = AverageColorFromImage([UIImage imageNamed:[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkImage) stringValue]]]);
    UIColor *secondaryContrastColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:secondaryColor isFlat:FALSE alpha:1.0];
    
    // Ensure that the contrast color will always be readable by gradually lightening the secondary color
    UIColor *whiteColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:[UIColor blackColor] isFlat:FALSE alpha:1.0];
    int lightenCount = 0;
    int maxLightenAttempt = 70;
    while ([secondaryContrastColor isEqual:whiteColor] && lightenCount < maxLightenAttempt) {
        secondaryColor = [secondaryColor lightenByPercentage:.01];
        secondaryContrastColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:secondaryColor isFlat:FALSE alpha:1.0];
        lightenCount++;
    }
    if (lightenCount >= maxLightenAttempt) {
        secondaryColor = [UIColor whiteColor];
    }
    
    self.contrastColor = secondaryColor;
    self.unselectedColor = whiteColor;
    self.unselectedOpaqueColor = whiteColor;
    */
    
    //You could also use SLColorArt, but the color schemes come out ugly when there's a white background:
    SLColorArt *colorArt = [[UIImage imageNamed:[self.artSite.siteInfo valueForKey:[@(ArtSiteArtworkImage) stringValue]]] colorArt];
    
    self.schemeColor = colorArt.backgroundColor;
    
    // Ensure that we can always read white on the background color by gradually darkening it
    UIColor *schemeContrastColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.schemeColor isFlat:FALSE alpha:1.0];
    UIColor *blackColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:[UIColor whiteColor] isFlat:FALSE alpha:1.0];
    int darkenCount = 0;
    int maxDarkenAttempt = 70;
    while ([schemeContrastColor isEqual:blackColor] && darkenCount < maxDarkenAttempt) {
        self.schemeColor = [self.schemeColor darkenByPercentage:.01];
        schemeContrastColor = [UIColor colorWithContrastingBlackOrWhiteColorOn:self.schemeColor isFlat:FALSE alpha:1.0];
        darkenCount++;
    }
    if (darkenCount >= maxDarkenAttempt) {
        self.schemeColor = [UIColor blackColor];
    }
    
    self.contrastColor = colorArt.primaryColor;
    self.unselectedColor = colorArt.secondaryColor;
    self.unselectedOpaqueColor = colorArt.secondaryColor;
    
    // If we "miss" on any colors (like, if there's no image set) set default app colors
    if (self.schemeColor == nil || self.contrastColor == nil) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.schemeColor = appDelegate.mainColor;
        self.contrastColor = appDelegate.mainTintColor;
        self.unselectedColor = [UIColor whiteColor];
        self.unselectedOpaqueColor = [UIColor whiteColor];
    }
    
    // If a placeholder/error site shows up, set the color scheme to the normal app color scheme
    if ([[self.artSite.siteInfo valueForKey:[@(ArtSiteTitle) stringValue]] isEqualToString:@"-"] && [[self.artSite.siteInfo valueForKey:[@(ArtSiteArtist) stringValue]] isEqualToString:@"-"]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.schemeColor = appDelegate.mainColor;
        self.contrastColor = appDelegate.mainTintColor;
        self.unselectedColor = [UIColor whiteColor];
        self.unselectedOpaqueColor = [UIColor whiteColor];
    }
}

- (void)applyColorSchemeToViewNavigationBarAndTabBar {
    // Set navigation and tab bar colors if they exist
    if (self.schemeColor != nil && self.contrastColor) {
        self.navigationController.navigationBar.barTintColor = self.schemeColor;
        self.navigationController.navigationBar.tintColor = self.contrastColor;
        self.tabBarController.tabBar.barTintColor = self.schemeColor;
        self.tabBarController.tabBar.tintColor = self.contrastColor;
    }
}

- (UIColor *)mostColorfulInScheme:(NSArray *)colorScheme {
    // This is a silly little function I wrote to find the variance of the RGB colors in each color in a color scheme.
    // I figured since R=G=B means a color is on the black-to-white spectrum, finding whatever is the furthest from R=G=B would mean it's the most colorful.
    // And, um, colors are nice, right?
    
    int maxIndex = 0;
    float maxVar = 0;
    
    for (int index = 0; index < [colorScheme count]; index++) {
        CGFloat *red = (CGFloat *) calloc(1, sizeof(CGFloat));
        CGFloat *green = (CGFloat *) calloc(1, sizeof(CGFloat));
        CGFloat *blue = (CGFloat *) calloc(1, sizeof(CGFloat));
        CGFloat *alpha = (CGFloat *) calloc(1, sizeof(CGFloat));
        [[colorScheme objectAtIndex:index] getRed:red green:green blue:blue alpha:alpha];
        //NSLog(@"R:%f G:%f B:%f",*red,*green,*blue);
        
        CGFloat avg = (*red + *green + *blue) / 3.0;
        //NSLog(@"Average: %f",avg);
        CGFloat ri = powf(*red - avg, 2);
        CGFloat gi = powf(*green - avg, 2);
        CGFloat bi = powf(*blue - avg, 2);
        CGFloat var = sqrt(ri + gi + bi / 2);
        //NSLog(@"Variance: %f",var);
        if (var > maxVar) {
            maxVar = var;
            maxIndex = index;
        }
    }
    //NSLog(@"-----");
    
    return colorScheme[maxIndex];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == self.artImageScrollView) {
        return self.artImageView;
    }
    
    return nil;
}


@end
