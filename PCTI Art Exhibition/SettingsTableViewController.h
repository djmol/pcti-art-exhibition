//
//  SettingsTableViewController.h
//  PCTI Art Exhibition
//
//  Created by Dan on 3/8/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *automaticSiteUpdateLabel;
@property (weak, nonatomic) IBOutlet UISwitch *automaticSiteUpdateSwitch;
@property (weak, nonatomic) IBOutlet UILabel *viewIntroducitonLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *viewIntroductionCell;
@property (weak, nonatomic) IBOutlet UILabel *refreshRateLabel;
@property (weak, nonatomic) IBOutlet UISlider *refreshRateSlider;
@property (nonatomic, strong) NSArray *sectionTitleArray;

@end
