//
//  VisitorInformationViewController.h
//  PCTI Art Exhibition
//
//  Created by Dan on 3/8/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VisitorInformationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (nonatomic, weak) IBOutlet UIButton *directionsButton;
- (void)showDirections;

@end
