 //
//  BeaconMenuViewController.m
//  PCTI Art Exhibition
//
//  Created by Dan on 1/5/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "AppDelegate.h"
#import "ArtSite.h"
#import "BeaconMenuViewController.h"
#import "FeatureSiteTableCell.h"
#import "SiteTableCell.h"
#import "ArtworkViewController.h"
#import "IntroViewController.h"
#import "RotationUITabBarController.h"
//#import "NetworkingTools.h"
//#import <PINRemoteImage/PINRemoteImage.h>
//#import <PINRemoteImage/UIImageView+PINRemoteImage.h>
//#import <PINCache/PINCache.h>
#import <EstimoteSDK/EstimoteSDK.h>
#import <ChameleonFramework/Chameleon.h>

@interface BeaconMenuViewController () <ESTBeaconManagerDelegate>

// Beacon stuff
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) NSMutableArray *sitesByDistance; // An array of beacons, constantly being updated as beacons are being ranged
@property (nonatomic) NSMutableArray *sitesByListing; // An array of strings that holds sitesByBeacon's values, matching the order shown on sitesTableView
@property (nonatomic) NSDictionary *sitesByBeacon; // Immutable nested dictionaries, key = major:minor, value = all pertinent information in another dictionary
@property (nonatomic) NSDictionary *selectedSite;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic) NSURL *fileURL;

// UI
@property (nonatomic, strong) UIColor *mainColor;
@property (nonatomic, strong) UIColor *secondaryColor;

// Flags
@property (nonatomic) int refreshLogoRotationState;
@property (nonatomic) int autoUpdateCount;
@property (nonatomic) BOOL didRangeBeacons;
@property (nonatomic) BOOL didDisplayError;
@property (nonatomic) BOOL didReceiveLocationServicesRequest;
@end

@implementation BeaconMenuViewController

#pragma mark - Init & Dealloc

- (id)init {
    if (self = [super init]) {
        [self customInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self customInit];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self customInit];
    }
    
    return self;
}

-(void)customInit {
    // Anything you want called on init goes in here.
    // This notification is only necessary if we're downloading beacon information.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:@"PlistDownloadNotification" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Display introduction on first launch
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenIntro"]) {
        // We might get a warning if we display the intro normally, so we call the displayIntroduction method in a weird way here.
        // The warning comes up because we're trying to present a VC before the tab bar VC stack can set up.
        // Q: If there's no delay, why does this work?
        // A: This queues the task up on the current thread, which is already loaded up with the rest of the tab bar VC setup.
        [self performSelector:@selector(displayIntroduction) withObject:nil afterDelay:0.0];
    }
    
    // Start downloading beacon information
    /*NSDictionary *resourceDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:@"Resources" ofType:@"plist"]];
    self.fileURL = [NSURL URLWithString:[resourceDict valueForKey:@"BeaconInfoURL"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NetworkingTools downloadPlistFromURL:self.fileURL notifyAt:@"PlistDownloadNotification"];
    });*/
    
    // Load beacon information from Sites.plist into sitesByBeacon
    // (This is a bunch of dictionaries in a dictionary. Each dictionary corresponds to an ArtSite.)
    self.sitesByBeacon = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:@"Sites" ofType:@"plist"]];
    
    // Instantiate the beacon manager & set its delegate
    self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self;
    // Instantiate the beacon region (our UUID is super important! don't change that string unless you change the UUID!)
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B40F4FFF-B83B-3675-96F6-EA410C519775"] identifier:@"ranged region"];
    // (Try to) request location services (again) on launches after the initial one
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenIntro"]) {
        //[self.beaconManager requestAlwaysAuthorization];
    }
    
    // Set navigation bar title
    self.navigationItem.title = NSLocalizedString(@"TITLE_BEACON_MENU", nil);
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    // Initialize footer for sitesTableView
    self.sitesTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Initialize refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.refreshControl.backgroundColor = appDelegate.secondaryColor;
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(reloadSitesDataWithAnimation) forControlEvents:UIControlEventValueChanged];
    [self.sitesTableView addSubview:self.refreshControl];
    
    // Set up refresh logo image views
    self.logoInner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh-logo-inner"]];
    self.logoOuter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refresh-logo-outer"]];
    [self.refreshControl addSubview:self.logoInner];
    [self.refreshControl addSubview:self.logoOuter];
    self.refreshControl.tintColor = [UIColor clearColor];
    self.refreshControl.clipsToBounds = YES;
    self.refreshLogoRotationState = 0;
    
    // Check for 3D Touch and register preview
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] && (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)) {
        [self registerForPreviewingWithDelegate:self sourceView:self.sitesTableView];
    }

    // Initial UI update
    [self performSelector:@selector(reloadSitesDataWithoutAnimation) withObject:nil afterDelay:0.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set/reset flags
    self.didRangeBeacons = FALSE;
    self.didDisplayError = FALSE;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenIntro"]) {
        self.didReceiveLocationServicesRequest = TRUE;
    }
    
    // Set colors
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[self transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Set colors with transition
        self.navigationController.navigationBar.barTintColor = appDelegate.mainColor;
        self.navigationController.navigationBar.tintColor = appDelegate.mainTintColor;
        self.tabBarController.tabBar.barTintColor = appDelegate.mainColor;
        self.tabBarController.tabBar.tintColor = appDelegate.mainTintColor;
    } completion:nil];
    
    // Set selected tab bar item text color (doing this in transition gives a dumb "HERE I AM" animation to the entire item)
    [[self.tabBarController.tabBar.items objectAtIndex:0] // Note that this index is hard-coded. It's not ideal, but there are more pressing issues atm.
     setTitleTextAttributes:@{ NSForegroundColorAttributeName : appDelegate.mainTintColor } forState:UIControlStateSelected];
    
    // Set colors if we're not using a transition
    if (![self transitionCoordinator]) {
        self.navigationController.navigationBar.barTintColor = appDelegate.mainColor;
        self.navigationController.navigationBar.tintColor = appDelegate.mainTintColor;
        self.tabBarController.tabBar.barTintColor = appDelegate.mainColor;
        self.tabBarController.tabBar.tintColor = appDelegate.mainTintColor;
    }
    
    // Start ranging or tell the user that their device is old and bad
    if ([CLLocationManager isRangingAvailable]) {
        [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    } else if (![CLLocationManager isRangingAvailable] && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenIntro"] && self.didDisplayError == FALSE) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_IBEACONS_NOT_SUPPORTED", nil)
                                                        message:NSLocalizedString(@"ERROR_IBEACONS_NOT_SUPPORTED_DETAIL", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        self.didDisplayError = TRUE;
    } 
    
    // Deselect selected tableview cell (remove the uggo gray highlight)
    [self.sitesTableView deselectRowAtIndexPath:[self.sitesTableView indexPathForSelectedRow] animated:YES];
    self.selectedSite = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    // Add Directions Quick Action
    if ([UIApplicationShortcutItem class]) {
        //UIApplicationShortcutIcon *directionsIcon = [[UIApplicationShortcutIcon alloc] init];
        UIApplicationShortcutIcon *directionsIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"qa-soca"];
        UIApplicationShortcutItem *directionsItem = [[UIApplicationShortcutItem alloc]
                                                     initWithType:@"us.nj.tec.pcti.shortcutitem.directions"
                                                     localizedTitle:NSLocalizedString(@"QUICK_ACTION_DIRECTIONS_TO_SHOW", nil)
                                                     localizedSubtitle:@""
                                                     icon:directionsIcon
                                                     userInfo:nil];
        NSArray *shortcutArray = @[directionsItem];
        [UIApplication sharedApplication].shortcutItems = shortcutArray;
    }
}



- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
}

#pragma mark - Introduction

- (void)displayIntroduction {
    // Set page indicator colors
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    pageControl.currentPageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    pageControl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    
    // Seems like this is necessary in iOS 8...
    [self performSelector:@selector(delayedDisplayIntroduction) withObject:nil afterDelay:0.0];
}

- (void)delayedDisplayIntroduction {
    // Present introduction modally
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IntroViewController *introViewController = [storyboard instantiateViewControllerWithIdentifier:@"Intro"];
    [self.tabBarController presentViewController:introViewController animated:NO completion:nil];
    /*[UIView transitionWithView:self.view.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.tabBarController presentViewController:introViewController animated:NO completion:nil];
                    }
                    completion:nil];*/
}

#pragma mark - Beacons

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    self.sitesByDistance = [self getSitesByBeacons:beacons];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"settingAutoUpdate"]) {
        self.autoUpdateCount++;
        //NSLog(@"%d",self.autoUpdateCount);
        // This 10 should be set to the max value of SettingsTableViewController's refreshRateSlider + 1, but it was a last-minute addition, so...
        if (self.autoUpdateCount >=  11 - [[[NSUserDefaults standardUserDefaults] valueForKey:@"autoUpdateRefreshRate"] floatValue]) {
            [self reloadSitesDataWithoutAnimation];
            self.autoUpdateCount = 0;
        }
    }
    
    if (!self.didRangeBeacons) {
        if ([self.sitesByListing count] == 0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"settingAutoUpdate"]) {
            [self reloadSitesDataWithoutAnimation];
        }
        self.didRangeBeacons = TRUE;
    }
}

- (NSMutableArray *)getSitesByBeacons:(NSArray *)beacons {
    NSMutableArray *sites = [[NSMutableArray alloc] init];
    NSUInteger count = 0;
    
    for (CLBeacon *beacon in beacons) {
        NSString *beaconKey = [NSString stringWithFormat:@"%@:%@", beacon.major, beacon.minor];
        // Preventing outOfBounds errors due to slow downloads or whatever
        if (count < [self.sitesByBeacon count]) {
            // Make sure we're only look at beacons that we have information for
            if ([self.sitesByBeacon objectForKey:beaconKey] != nil)
                [sites addObject:[self.sitesByBeacon objectForKey:beaconKey]];
        }
        count++;
    }
    
    return sites;
}

-(void)beaconManager:(id)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    // Only display an error alert once per view-appear, and only after the intro has been dismissed
    if (!self.didDisplayError && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenIntro"]) {
        UIAlertController *alertController;
        
        // Create alert actions
        //UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_RESPONSE_CANCEL", nil) style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_RESPONSE_OK", nil) style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_RESPONSE_SETTINGS", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            });
        }];
        
        // CoreLocation error codes
        if (error.code == kCLErrorDenied && [error.domain isEqualToString:@"kCLErrorDomain"]) {
            alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ERROR_LOCATION_SERVICES_DISABLED", nil)
                                                                  message:NSLocalizedString(@"ERROR_LOCATION_SERVICES_DISABLED_DETAIL_WITH_SETTINGS", nil)
                                                           preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:okAction];
            [alertController addAction:settingsAction];
            
        } else if (error.code == kCLErrorNetwork && [error.domain isEqualToString:@"kCLErrorDomain"]) {
            alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ERROR_NETWORK_UNAVAILABLE", nil)
                                                                  message:NSLocalizedString(@"ERROR_NETWORK_UNAVAILABLE", nil)
                                                           preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:okAction];
        } else if (error.code == kCLErrorRangingUnavailable && [error.domain isEqualToString:@"kCLErrorDomain"]) {
            alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ERROR_RANGING_UNAVAILABLE", nil)
                                                                  message:NSLocalizedString(@"ERROR_RANGING_UNAVAILABLE_DETAIL", nil)
                                                           preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:okAction];
        } else if (error.code == kCLErrorLocationUnknown && [error.domain isEqualToString:@"kCLErrorDomain"]) {
            alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ERROR_LOCATION_UNKNOWN", nil)
                                                                  message:NSLocalizedString(@"ERROR_LOCATION_UNKNOWN_DETAIL", nil)
                                                           preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:okAction];
        } else if ((error.code == kCLErrorRegionMonitoringDenied || error.code == kCLErrorRegionMonitoringFailure ||
                   error.code == kCLErrorRegionMonitoringSetupDelayed || error.code == kCLErrorRegionMonitoringResponseDelayed) && [error.domain isEqualToString:@"kCLErrorDomain"]) {
            alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ERROR_REGION_MONITORING", nil)
                                                                  message:NSLocalizedString(@"ERROR_REGION_MONITORING_DETAIL", nil)
                                                           preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:okAction];
        }
        // ESTBeaconManager error codes
        else if (error.code == ESTBeaconManagerErrorInvalidRegion && [error.domain isEqualToString:@"ESTBeaconManagerErrorDomain"]) {
            alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ERROR_EST_INVALID_REGION", nil)
                                                                  message:NSLocalizedString(@"ERROR_EST_INVALID_REGION_DETAIL", nil)
                                                           preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:okAction];
        } else if (error.code == ESTBeaconManagerErrorLocationServicesUnauthorized && [error.domain isEqualToString:@"ESTBeaconManagerErrorDomain"]) {
            alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ERROR_LOCATION_SERVICES_DISABLED", nil)
                                                                  message:NSLocalizedString(@"ERROR_LOCATION_SERVICES_DISABLED_DETAIL_WITH_SETTINGS", nil)
                                                           preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:okAction];
            [alertController addAction:settingsAction];
        } /*else {
           // Catch-all error?
        }*/
        
        [self.tabBarController presentViewController:alertController animated:YES completion:nil];
        self.didDisplayError = TRUE;
    }
         
}
    
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sitesByDistance count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // Create cells using custom layouts
    if (indexPath.row == 0) {
        // Feature Site Table Cell, for the closest beacon only
        static NSString *tableIdentifier = @"FeatureSiteTableCell";
        FeatureSiteTableCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
        
        // Get screen height to determine which feature site table cell layout to use
        float screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        if (cell == nil) {
            if (screenHeight == 480 || screenHeight == 568) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FeatureSiteTableCellSmall" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            } else if (screenHeight == 1024 || screenHeight == 1366) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FeatureSiteTableCellLarge" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            } else {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FeatureSiteTableCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
        }
        
        // Get site information for cell
        ArtSite *artSite = [[ArtSite alloc] init];
        
        if (self.sitesByDistance.count > indexPath.row) {
            artSite.siteInfo = [[NSDictionary alloc] initWithDictionary:[self.sitesByDistance objectAtIndex:indexPath.row]];
        } else {
            // Use default/error/dummy information
            artSite.siteInfo = [[NSDictionary alloc] initWithDictionary:[self.sitesByBeacon objectForKey:@"x:x"]];
        }
        
        // Set cell information
        cell.titleLabel.text = [artSite.siteInfo valueForKey:[@(ArtSiteTitle) stringValue]];
        cell.artistLabel.text = [artSite.siteInfo valueForKey:[@(ArtSiteArtist) stringValue]];
        //cell.descriptionLabel.text = [artSite.siteInfo valueForKey:[@(ArtSiteDescription) stringValue]];
        //[cell.descriptionLabel sizeToFit];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // Set image without download
        cell.thumbnailImageView.image = [UIImage imageNamed:[artSite.siteInfo valueForKey:[@(ArtSiteArtworkImage) stringValue]]];
        
        // Setup activity indicator
        /*UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator setCenter:cell.thumbnailImageView.center];
        [cell.contentView addSubview:activityIndicator];*/
        
        // Get image URL and download image
        /*NSDictionary *resourceDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:@"Resources" ofType:@"plist"]];
        NSMutableString *imageURLString = [[NSMutableString alloc] initWithString:[resourceDict valueForKey:@"URLPrefix"]];
        [imageURLString appendString:[artSite.siteInfo valueForKey:@"ArtworkImage"]];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];*/
        
        // PINRemoteImage version of download
        //[cell.thumbnailImageView pin_setImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
        // AFNetworking version of download
        /*dispatch_async(dispatch_get_main_queue(), ^{
            [NetworkingTools downloadImageFromURL:imageURL toView:cell.thumbnailImageView withActivity:activityIndicator];
        });*/
        
        return cell;
    } else {
        // Site Table Cell, for all other ranged beacons
        static NSString *tableIdentifier = @"SiteTableCell";
        SiteTableCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SiteTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        // Get site information for cell
        ArtSite *artSite = [[ArtSite alloc] init];
        
        if (self.sitesByDistance.count > indexPath.row) {
            artSite.siteInfo = [[NSDictionary alloc] initWithDictionary:[self.sitesByDistance objectAtIndex:indexPath.row]];
        } else {
            // Use default/error/dummy information
            artSite.siteInfo = [[NSDictionary alloc] initWithDictionary:[self.sitesByBeacon objectForKey:@"x:x"]];
        }
        
        // Set cell information
        cell.titleLabel.text = [artSite.siteInfo valueForKey:[@(ArtSiteTitle) stringValue]];
        cell.artistLabel.text = [artSite.siteInfo valueForKey:[@(ArtSiteArtist) stringValue]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // Set image without download
        cell.thumbnailImageView.image = [UIImage imageNamed:[artSite.siteInfo valueForKey:[@(ArtSiteArtworkImage) stringValue]]];
        
        // Setup activity indicator
        /*UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator setCenter:cell.thumbnailImageView.center];
        [cell.contentView addSubview:activityIndicator];*/
        
        // Get image URL and download image
        /*NSDictionary *resourceDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:@"Resources" ofType:@"plist"]];
        NSMutableString *imageURLString = [[NSMutableString alloc] initWithString:[resourceDict valueForKey:@"URLPrefix"]];
        [imageURLString appendString:[artSite.siteInfo valueForKey:@"ArtworkImage"]];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];*/
        
        // PINRemoteImage version of download
        //[cell.thumbnailImageView pin_setImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
        // AFNetworking version of download
        /*dispatch_async(dispatch_get_main_queue(), ^{
         [NetworkingTools downloadImageFromURL:imageURL toView:cell.thumbnailImageView withActivity:activityIndicator];
         });*/
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Can these magic numbers be avoided? :/
    if (indexPath.row == 0) {
       // Feature Site Table Cell, for closest beacon
       float screenHeight = [UIScreen mainScreen].bounds.size.height;
       if (screenHeight == 480) {
           // iPhone 4S
           return 140;
       } else if (screenHeight == 568) {
           // iPhone 5
           return 160;
       } else if (screenHeight == 667) {
           // iPhone 6
           return 195;
       } else if (screenHeight == 736) {
           // iPhone 6+
           return 210;
       } else if (screenHeight == 1024 || screenHeight == 1366) {
           // iPad
           return 365;
       } else {
           return 210;
       }
    } else {
       // Site Table Cell, for all other ranged beacons
       return 78;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Update model with the beacon site we've selected and begin segue
    self.selectedSite = [self.sitesByBeacon valueForKey:[[self.sitesByListing objectAtIndex:indexPath.row] valueForKey:[@(ArtSiteMajorMinor) stringValue]]];
    [self performSegueWithIdentifier:@"toArtworkViewController" sender:self];
}

#pragma mark - Table View Data Source

- (IBAction)touchRefreshButton:(id)sender {
    // We only can/need to clear the cache if we're downloading
    //[self clearBeaconImageCache];
    [self reloadSitesDataWithoutAnimation];
}

- (void)reloadSitesDataWithoutAnimation {
    [self reloadSitesDataWithAnimation:NO];
}

- (void)reloadSitesDataWithAnimation {
    [self reloadSitesDataWithAnimation:YES];
}

- (void)reloadSitesDataWithAnimation:(BOOL)animation {
    // This method has two separate proxy(? I can't think of the right term) methods (reloadSitesDataWithoutAnimation and reloadSitesDataWithAnimation) for simpler organization and use as selectors
    
    // Try this again? (As it is, we'll have to change refreshControl's vertical bounds)
    /*NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;*/
    
    // Reset our auto-update counter so it doesn't auto-update right after we manually refresh
    self.autoUpdateCount = 0;
    
    // If we're doing animation, spin the logo!
    if (animation) {
        [self animateRefreshView];
    }
    
    // Reload data in sitesTableView
    [self.sitesTableView reloadData];
    
    // FOR DEVELOPMENT: Display all beacons
    //self.sitesByDistance = [[NSMutableArray alloc] init]; for (NSString *beaconSite in self.sitesByBeacon) { [self.sitesByDistance addObject:[self.sitesByBeacon valueForKey:beaconSite]]; }
    
    // Update sitesByListing so that it holds the currently displayed list of sites while sitesByDistance keeps updating
    //self.sitesByListing = self.sitesByDistance;
    self.sitesByListing = [NSMutableArray arrayWithArray:self.sitesByDistance];
    
    // If it's animated, set a bit of a delay to show it's working...
    if (animation) {
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // When done reloading, invoke endRefreshing to close the refresh control
            [self.refreshControl endRefreshing];
        });
    } else {
        [self.refreshControl endRefreshing];
    }
}

- (void)animateRefreshView {
    // This rotates the image in 3D around the y-axis
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // Rotate the spinner halfway
                         self.logoInner.layer.transform = CATransform3DScale(CATransform3DMakeRotation(M_PI * 2.0f, 0, 0, 1), -1, 1, 1);
                         if (self.refreshLogoRotationState == 0) {
                             self.refreshLogoRotationState = 1;
                         } else {
                             self.refreshLogoRotationState = 0;
                         }
                         
                     }
                     completion:^(BOOL finished) {
                         // Rotate the spinner the other halfway
                         [UIView animateWithDuration:0.3
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              self.logoInner.layer.transform = CATransform3DScale(self.logoInner.layer.transform, -1, 1, 1);
                                              if (self.refreshLogoRotationState == 0) {
                                                  self.refreshLogoRotationState = 1;
                                              } else {
                                                  self.refreshLogoRotationState = 0;
                                              }
                                          }
                                          completion:^(BOOL finished) {
                                              // If still refreshing, keep spinning, else reset
                                              if (self.refreshControl.isRefreshing) {
                                                  [self animateRefreshView];
                                              } else {
                                                  // Do any reset stuff here.
                                              }
                                          }];
                     }];
    
    // This rotates the image in 2D
    /*[UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                         [self.logoInner setTransform:CGAffineTransformRotate(self.logoInner.transform, M_PI)];
                         if (self.refreshLogoRotationState == 0) {
                             self.refreshLogoRotationState = 1;
                         } else {
                             self.refreshLogoRotationState = 0;
                         }
                         
                     }
                     completion:^(BOOL finished) {
                         // If still refreshing, keep spinning, else reset
                         if (self.refreshControl.isRefreshing) {
                          [self animateRefreshView];
                          } else {
                          // Do any reset stuff here.
                          }
                     }];*/
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Adapted from JackrabbitMobile's JackrabbitRefresh
    // Distance the table has been pulled >= 0
    CGFloat pullDistance = MAX(0.0, -self.refreshControl.frame.origin.y);
    
    // PCTI Logo Disrespect Sensor (for 2D rotation)
    // (If the table scrolls back to the top, rotate the refresh logo back upright, if necessary.)
    if (pullDistance == 0.0 && self.refreshLogoRotationState == 1 && !self.refreshControl.isRefreshing) {
        [UIView animateWithDuration:0.0
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                             [self.logoInner setTransform:CGAffineTransformRotate(self.logoInner.transform, M_PI)];
                         }
                         completion:nil];
        self.refreshLogoRotationState = 0;
    }
    
    // Half the width of the table
    CGFloat midX = self.sitesTableView.frame.size.width / 2.0;
    
    // Calculate the width and height of our graphics
    CGFloat logoHeight = self.logoOuter.bounds.size.height;
    CGFloat logoHeightHalf = logoHeight / 2.0;
    
    CGFloat logoWidth = self.logoOuter.bounds.size.width;
    CGFloat logoWidthHalf = logoWidth / 2.0;
    
    // Set the Y coord of the graphics, based on pull distance
    CGFloat logoY = pullDistance / 2.0 - logoHeightHalf;
    
    // Calculate the X coord of the graphics, adjust based on pull ratio
    CGFloat logoX = midX - logoWidthHalf;
    
    // Set the graphic's frames
    CGRect logoFrame = self.logoOuter.frame;
    logoFrame.origin.x = logoX;
    logoFrame.origin.y = logoY;
    
    self.logoOuter.frame = logoFrame;
    self.logoInner.frame = logoFrame;
    
    // Set the encompassing view's frames
    //refreshBounds.size.height = pullDistance;
    
    //self.refreshLoadingView.frame = refreshBounds;
    
    // If we're refreshing and the animation is not playing, then play the animation
    /*if (self.refreshControl.isRefreshing && !self.isRefreshAnimating) {
        [self animateRefreshView];
    }*/
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger numSections = 0;
    
    if (self.sitesByDistance.count > 0) {
        self.sitesTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.sitesTableView.backgroundView = nil;
        self.sitesTableView.backgroundColor = nil;
        numSections = 1;
    } else {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - (self.view.bounds.size.width / 6), self.view.bounds.size.height)];
        
        // The label properties are separated out in case we want to make one/some of them "pop," as un-iOS as that may be
        if (![CLLocationManager isRangingAvailable]) {
            // iBeacons unsupported message
            messageLabel.text = NSLocalizedString(@"BEACON_MENU_IBEACONS_NOT_SUPPORTED", nil);
            messageLabel.textColor = [UIColor grayColor];
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            [messageLabel sizeToFit];
        } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"settingAutoUpdate"]) {
            // "No data..." message on auto refresh
            messageLabel.text = NSLocalizedString(@"BEACON_MENU_NO_DATA_AUTO_REFRESH", nil);
            messageLabel.textColor = [UIColor grayColor];
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            [messageLabel sizeToFit];
        } else {
            // "No data..." message on manual refresh
            messageLabel.text = NSLocalizedString(@"BEACON_MENU_NO_DATA_MANUAL_REFRESH", nil);
            messageLabel.textColor = [UIColor grayColor];
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            [messageLabel sizeToFit];
        }
        
        self.sitesTableView.backgroundView = messageLabel;
        //self.sitesTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pulldown"]];
        self.sitesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return numSections;
}

- (void)clearBeaconImageCache {
    // Delete previously downloaded Sites.plist file
    NSString *fileName = @"Sites.plist";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"Stored file deleted.");
    } else {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    
    // Redownload Sites.plist
    /*dispatch_async(dispatch_get_main_queue(), ^{
        [NetworkingTools downloadPlistFromURL:self.fileURL notifyAt:@"PlistDownloadNotification"];
    });*/
    
    // Get general image URL prefix
    NSDictionary *resourceDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:@"Resources" ofType:@"plist"]];
    NSMutableString *imageURLString = [[NSMutableString alloc] initWithString:[resourceDict valueForKey:@"URLPrefix"]];
    
    for (NSString *key in self.sitesByBeacon) {
        ArtSite *artSite = [[ArtSite alloc] init];
        artSite.siteInfo = [self.sitesByBeacon valueForKey:key];
        // Create image URL and manually empty cache
        [imageURLString appendString:[artSite.siteInfo valueForKey:[@(ArtSiteArtworkImage) stringValue]]];
        //NSURL *imageURL = [NSURL URLWithString:imageURLString];
        //[[[PINRemoteImageManager sharedImageManager] cache] removeObjectForKey:[[PINRemoteImageManager sharedImageManager] cacheKeyForURL:imageURL processorKey:nil]];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toArtworkViewController"]) {
        // Segue to web view, sending pertinent information about the artwork
        ArtworkViewController *artworkViewController = (ArtworkViewController *) segue.destinationViewController;
        artworkViewController.artSite = [[ArtSite alloc] initWithSiteInfo:self.selectedSite];
    }
}

#pragma mark - Notifications

- (void) receivedNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"PlistDownloadNotification"]) {
        self.sitesByBeacon = notification.userInfo;
    }
}

#pragma mark - 3D Touch - Peek & Pop

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.sitesTableView indexPathForRowAtPoint:location];
    UITableViewCell *cell = [self.sitesTableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        // Set preview frame
        previewingContext.sourceRect = cell.frame;
        
        // Get selected site information
        NSDictionary *selectedSite = [[NSDictionary alloc] initWithDictionary:[self.sitesByListing objectAtIndex:indexPath.row]];
        
        // Set up our VCs...
        RotationUITabBarController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
        // Set the tab bar to the Tour index. Note that this may break if you rearrange the tab bar!
        tabBarController.selectedViewController =  [tabBarController.viewControllers objectAtIndex:0];
        UINavigationController *navigationController = tabBarController.selectedViewController;
        [navigationController popToRootViewControllerAnimated:false];
        ArtworkViewController *artworkViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Artwork"];
        artworkViewController.artSite = [[ArtSite alloc] initWithSiteInfo:selectedSite];
        [navigationController pushViewController:artworkViewController animated:NO];
        [(ArtworkViewController *)[[navigationController childViewControllers] objectAtIndex:1] setViewColorScheme];
        [(ArtworkViewController *)[[navigationController childViewControllers] objectAtIndex:1] applyColorSchemeToViewNavigationBarAndTabBar];
        return tabBarController;
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showDetailViewController:viewControllerToCommit sender:self];
}

@end
