//
//  VisitorInformationViewController.m
//  PCTI Art Exhibition
//
//  Created by Dan on 3/8/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "AppDelegate.h"
#import "RotationUITabBarController.h"
#import "VisitorInformationViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import <MapKit/MapKit.h>

@implementation VisitorInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set navigation bar title
    self.navigationItem.title = NSLocalizedString(@"TITLE_VISITOR_INFORMATION", nil);
    
    // Set information text
    NSString *infoText = @"\nWhen does the PCTI Art Show open?\nMay 25, 6:30pm\n\nWhere is the PCTI Art Show?\nThe 2016 PCTI Art Show will be held at Lambert Castle, 3 Valley Road, Paterson, NJ.\n\nWhat is the admission fee?\nAdmission to the PCTI Art Show is free. Regular admission to Lambert Castle is $5.00 for Adults, $4.00 for Senior Citizens (65+), $3.00 for Children (5-17), and free for Children (5 and under).\n\nAbout Lambert Castle\nLambert Castle is a nationally-recognized historic landmark located on Garrett Mountain, overlooking the City of Paterson. Built in 1892 by Catholina Lambert, the owner of a prominent silk mill, the castle originally served as the Lambert family's private residence. Now owned by the Passaic County Park Commission, the castle houses a museum and library. It was recently restored through a $5 million renewal project to preserve its status as an icon in Passaic County history.";
    NSArray *boldSubstrings = @[@"When does the PCTI Art Show open?",
                                @"Where is the PCTI Art Show?",
                                @"What is the admission fee?",
                                @"About Lambert Castle"];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:infoText];
    UIFont *boldText = [UIFont boldSystemFontOfSize:13];
    
    for (NSString *substring in boldSubstrings) {
        NSRange rangeBold = [infoText rangeOfString:substring];
        [attributedText addAttribute:NSFontAttributeName value:boldText range:rangeBold];
    }

    // Set infoTextView content size
    int insetSize = 12;
    [self.infoTextView setTextContainerInset:UIEdgeInsetsMake(0, insetSize, 0, insetSize)];
    self.infoTextView.showsHorizontalScrollIndicator = NO;
    self.infoTextView.contentSize = CGSizeMake(self.infoTextView.frame.size.width - (insetSize * 2), self.infoTextView.frame.size.height);
    [self.infoTextView setContentOffset:CGPointMake(0,-500) animated:YES];
    
    /*NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
    NSMutableAttributedString *mutAttrTextViewString = [[NSMutableAttributedString alloc] initWithString:infoText];
    [mutAttrTextViewString setAttributes:dictBoldText range:rangeBold];*/
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self setButton:self.directionsButton titleText:NSLocalizedString(@"VISITOR_INFORMATION_DIRECTIONS_LINK", nil)];
    self.directionsButton.backgroundColor = appDelegate.secondaryColor;
    [self.directionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.infoTextView setAttributedText:attributedText];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set colors
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationController.navigationBar.barTintColor = appDelegate.mainColor;
    self.navigationController.navigationBar.tintColor = appDelegate.mainTintColor;
    self.tabBarController.tabBar.barTintColor = appDelegate.mainColor;
    self.tabBarController.tabBar.tintColor = appDelegate.mainTintColor;
    [[self.tabBarController.tabBar.items objectAtIndex:1] // Note that this index is hard-coded. It's not ideal, but there are more pressing issues atm.
        setTitleTextAttributes:@{ NSForegroundColorAttributeName : appDelegate.mainTintColor } forState:UIControlStateSelected];
    
    //RotationUITabBarController *tabBarController = (RotationUITabBarController *)self.tabBarController;
    //[tabBarController setTabBarItemColorsWithSelectedColor:appDelegate.mainTintColor unselectedColor:ContrastColor(appDelegate.mainColor, TRUE)];
}

- (IBAction)directionsButtonTouched:(id)sender {
    [self showDirections];
}

- (void)showDirections {
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    
    // Create destination data for Lambert Castle
    double latitude = 40.899222;
    double longitude = -74.172620;
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:@"Lambert Castle"];
    
    directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
    directionsRequest.destination = mapItem;
    directionsRequest.requestsAlternateRoutes = YES;
    
    NSDictionary *launchOptions = @{ MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
                                     MKLaunchOptionsMapTypeKey : [NSNumber numberWithUnsignedInteger:MKMapTypeStandard],
                                     MKLaunchOptionsMapCenterKey : [NSValue valueWithMKCoordinate:[placemark coordinate]],
                                     //MKLaunchOptionsMapSpanKey:,
                                     MKLaunchOptionsShowsTrafficKey : @FALSE };
    
    [mapItem openInMapsWithLaunchOptions:launchOptions];
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
