//
//  SiteTableCell.h
//  PCTI Art Exhibition
//
//  Created by Dan on 1/6/16.
//  Copyright © 2016 Passaic County Technical Institute. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SiteTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;

@end
