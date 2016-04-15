//
//  SettingsTableViewController.m
//  PCTI Art Exhibition
//
//  Created by Dan on 3/8/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import "AppDelegate.h"
#import "IntroViewController.h"
#import "RotationUITabBarController.h"
#import "SettingsTableViewController.h"
#import <ChameleonFramework/Chameleon.h>

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set navigation bar title
    self.navigationItem.title = NSLocalizedString(@"TITLE_SETTINGS_TABLE", nil);
    
    // Set localized control strings
    self.automaticSiteUpdateLabel.text = NSLocalizedString(@"SETTINGS_AUTOMATIC_SITE_UPDATE_LABEL", nil);
    self.refreshRateLabel.text = NSLocalizedString(@"SETTINGS_REFRESH_RATE_LABEL", nil);
    self.viewIntroducitonLabel.text = NSLocalizedString(@"SETTINGS_VIEW_INTRODUCTION_LABEL", nil);
    self.sectionTitleArray = @[NSLocalizedString(@"SETTINGS_SECTION_HEADING_1", nil), NSLocalizedString(@"SETTINGS_SECTION_HEADING_2", nil)];
    
    // Set options controls to appear as what they're currently set to
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"settingAutoUpdate"]) {
        [self.automaticSiteUpdateSwitch setOn:TRUE];
        self.refreshRateSlider.enabled = TRUE;
    } else {
        [self.automaticSiteUpdateSwitch setOn:FALSE];
        self.refreshRateSlider.enabled = FALSE;
    }
    [self.refreshRateSlider setValue:[[[NSUserDefaults standardUserDefaults] valueForKey:@"autoUpdateRefreshRate"] floatValue]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set colors
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.navigationController.navigationBar.barTintColor = appDelegate.mainColor;
    self.navigationController.navigationBar.tintColor = appDelegate.mainTintColor;
    self.tabBarController.tabBar.barTintColor = appDelegate.mainColor;
    self.tabBarController.tabBar.tintColor = appDelegate.mainTintColor;
    [[self.tabBarController.tabBar.items objectAtIndex:2] // Note that this index is hard-coded. It's not ideal, but there are more pressing issues atm.
        setTitleTextAttributes:@{ NSForegroundColorAttributeName : appDelegate.mainTintColor } forState:UIControlStateSelected];
    
    //RotationUITabBarController *tabBarController = (RotationUITabBarController *)self.tabBarController;
    //[tabBarController setTabBarItemColorsWithSelectedColor:appDelegate.mainTintColor unselectedColor:ContrastColor(appDelegate.mainColor, TRUE)];
}

- (IBAction)automaticSiteUpdateSwitchToggled:(id)sender {
    if ([self.automaticSiteUpdateSwitch isOn]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"settingAutoUpdate"];
        self.refreshRateSlider.enabled = TRUE;
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"settingAutoUpdate"];
        self.refreshRateSlider.enabled = FALSE;
    }
}

- (IBAction)refreshRateSliderChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:self.refreshRateSlider.value] forKey:@"autoUpdateRefreshRate"];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitleArray objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    // View introduction again (this should probably just call beaconMenu's displayIntroduction...)
    if (selectedCell == self.viewIntroductionCell) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        IntroViewController *introViewController = [storyboard instantiateViewControllerWithIdentifier:@"Intro"];
        [UIView transitionWithView:self.view.window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self presentViewController:introViewController animated:NO completion:nil];
                        }
                        completion:nil];
    }
}

@end
