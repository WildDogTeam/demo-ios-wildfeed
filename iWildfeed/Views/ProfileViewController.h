//
//  ProfileViewController.h
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firefeed.h"
#import "MOGlassButton.h"

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) NSString* userId;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet UITextView *locationText;
@property (weak, nonatomic) IBOutlet MOGlassButton *actionButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end
