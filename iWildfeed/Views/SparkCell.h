//
//  SparkCell.h
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirefeedSpark.h"

@interface SparkCell : UITableViewCell

- (void) configureForSpark:(FirefeedSpark *)spark;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;

@property (strong, nonatomic) NSDateFormatter* dateFormatter;

@end
