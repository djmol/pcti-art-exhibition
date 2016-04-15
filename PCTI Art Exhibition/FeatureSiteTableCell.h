//
//  FeatureSiteTableCell.h
//  PCTI Art Exhibition
//
//  Created by Dan on 1/8/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeatureSiteTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end
