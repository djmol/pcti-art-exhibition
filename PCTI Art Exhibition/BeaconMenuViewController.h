//
//  BeaconMenuViewController.h
//  PCTI Art Exhibition
//
//  Created by Dan on 1/5/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EstimoteSDK/EstimoteSDK.h>

@interface BeaconMenuViewController : UIViewController <UIViewControllerPreviewingDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *sitesTableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, strong) UIImageView *logoOuter;
@property (nonatomic, strong) UIImageView *logoInner;
@property (nonatomic, strong) ESTBeaconManager *beaconManager;

@end

