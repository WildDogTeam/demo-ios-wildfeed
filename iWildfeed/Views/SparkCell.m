//
//  SparkCell.m
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "SparkCell.h"
#import "UIImageView+WebCache.h"

@implementation SparkCell

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.locale = [NSLocale currentLocale];
        self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
        self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureForSpark:(FirefeedSpark *)spark {
    // Map the data in the spark to our view.
    self.contentTextView.text = spark.content;
    self.contentTextView.contentOffset = CGPointZero;
    self.contentTextView.contentInset = UIEdgeInsetsMake(-10, -5, -5, -5);
    self.contentTextView.userInteractionEnabled = NO;
    self.authorLabel.text = spark.authorName;
    [self.profileImage sd_setImageWithURL:spark.authorPicURL placeholderImage:[UIImage imageNamed:@"placekitten.png"]];
    NSTimeInterval interval = spark.timestamp / 1000.0;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSString* dateString = [self.dateFormatter stringFromDate:date];
    self.timestampLabel.text = dateString;
}

@end
