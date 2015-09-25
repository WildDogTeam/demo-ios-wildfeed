//
//  UserCell.m
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "UserCell.h"
#import "UIImageView+WebCache.h"

@implementation UserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) configureForUser:(FirefeedUser *)user {
    // Bind a FirefeedUser to this view
    self.nameLabel.text = user.fullName;
    [self.profilePic sd_setImageWithURL:user.picURLSmall placeholderImage:[UIImage imageNamed:@"placekitten.png"]];
    self.bioText.contentOffset = CGPointZero;
    self.bioText.contentInset = UIEdgeInsetsMake(-10, -5, -5, -5);
    self.bioText.text = user.bio;
    self.bioText.userInteractionEnabled = NO;
}

@end
