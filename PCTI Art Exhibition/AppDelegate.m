//
//  AppDelegate.m
//  PCTI Art Exhibition
//
//  Created by Dan on 1/5/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "AppDelegate.h"
#import "IntroViewController.h"
#import "RotationUITabBarController.h"
#import "VisitorInformationViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import <EstimoteSDK/EstimoteSDK.h>

@interface AppDelegate () <ESTBeaconManagerDelegate>

@property (nonatomic) ESTBeaconManager *beaconManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Monitoring regions & notifications ...?
    /*self.beaconManager = [ESTBeaconManager new];
    self.beaconManager.delegate = self;
    [self.beaconManager requestAlwaysAuthorization];
    [self.beaconManager startMonitoringForRegion:[[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B40F4FFF-B83B-3675-96F6-EA410C519775"] major:7073 minor:26290 identifier:@"monitored region"]];
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];*/
    
    // Should I bother downloading Resources.plist before BeaconMenuViewController loads?
    /*UINavigationController *mainNavigationController = (UINavigationController*) self.window.rootViewController;
    BeaconMenuViewController *mainViewController = (BeaconMenuViewController*)[mainNavigationController.childViewControllers objectAtIndex:0];
    NSDictionary *resourceDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]  pathForResource:@"Resources" ofType:@"plist"]];
    NSURL *fileURL = [NSURL URLWithString:[resourceDict valueForKey:@"BeaconInfoURL"]];
    dispatch_async(dispatch_get_main_queue(), ^{
     mainViewController.sitesByBeacon = [self downloadPlistFromURL:fileURL];
    });*/
    
    // Set status bar color
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Set user defaults
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"settingAutoUpdate"];
    [[NSUserDefaults standardUserDefaults] setValue:@"5" forKey:@"autoUpdateRefreshRate"];
    //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasSeenIntro"];
    
    // Set color scheme for app-wide use
    self.mainColor = HexColor(@"005CB9"); // Main blue
    self.mainTintColor = HexColor(@"8BC5FF"); // Light blue, not from PCTI color scheme
    self.secondaryColor = HexColor(@"6BC047"); // Accent green
    self.tertiaryColor = HexColor(@"004D73"); // Accent blue
    
    // Set up Estimote analytics
    [ESTConfig setupAppID:@"pcti-art-exhibition-neo" andAppToken:@"7d304da8d58d2ca492fc5ef6373b2dbc"];
    
    // Apply app-wide color scheme to controls
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [UISwitch appearance].onTintColor = self.secondaryColor;
    [UISlider appearance].tintColor = self.secondaryColor;
    [UISegmentedControl appearance].tintColor = self.tertiaryColor;
    //[UIButton appearance].tintColor = self.mainColor;
    
    // Check if application was launched with a Quick Action
    // (And check if quick actions even exist! They don't before iOS9.)
    if ([UIApplicationShortcutItem class]) {
        UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
        if ([shortcutItem.type isEqualToString:@"us.nj.tec.pcti.shortcutitem.directions"]) {
            [self launchToDirections];
        }
    }
    
    return YES;
}


- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    if ([shortcutItem.type isEqualToString:@"us.nj.tec.pcti.shortcutitem.directions"]) {
        [self launchToDirections];
    }
}

- (void)launchToDirections {
    // Set up our VCs...
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RotationUITabBarController *tabBarController = (RotationUITabBarController *)self.window.rootViewController;
    // Set the tab bar to the Visitor Info index. Note that this may break if you rearrange the tab bar!
    tabBarController.selectedViewController =  [tabBarController.viewControllers objectAtIndex:1];
    UINavigationController *navigationController = tabBarController.selectedViewController;
    [navigationController popToRootViewControllerAnimated:false];
    VisitorInformationViewController *visitorInfoViewController = navigationController.viewControllers[0];
    
    // Off to get our directions!
    // Invoking the method like this goes much more smoothly than doing it normally
    [visitorInfoViewController performSelector:@selector(showDirections) withObject:nil afterDelay:0.0];
}

/*
 - (void)launchToNearestBeacon {
 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
 NavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
 BeaconMenuViewController *beaconViewController = [storyboard instantiateViewControllerWithIdentifier:@"BeaconMenu"];
 ArtworkViewController *artViewController = [storyboard instantiateViewControllerWithIdentifier:@"Artwork"];
 BeaconMenuViewController *bvc = [self.window.rootViewController.childViewControllers objectAtIndex:0];
 artViewController.siteInfo = [bvc.sitesByDistance objectAtIndex:0];
 [navigationController pushViewController:beaconViewController animated:NO];
 [navigationController pushViewController:artViewController animated:NO];
 self.window.rootViewController = navigationController;
 [self.window makeKeyAndVisible];
 }
*/

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
