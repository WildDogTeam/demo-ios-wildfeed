//
//  ProfileEditController.m
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "ProfileEditController.h"
#import "ComposeViewController.h"
#import "Firefeed.h"
#import "FirefeedAuth.h"

typedef enum {BIO, LOCATION, NONE} UserProperty;

@interface ProfileEditController () <FirefeedDelegate, ComposeViewControllerDelegate>

@property (strong, nonatomic) UIColor* brownColor;
@property (strong, nonatomic) Firefeed* firefeed;
@property (strong, nonatomic) FirefeedUser* user;
@property (nonatomic) UserProperty currentlyEditing;
@property (strong, nonatomic) UIView* lineView;

@end

@implementation ProfileEditController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.brownColor = [UIColor colorWithRed:0x7b / 255.0f green:0x5f / 255.0f blue:0x11 / 255.0f alpha:1.0f];
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Edit Profile" image:[UIImage imageNamed:@"edit.png"] tag:0];
        self.firefeed = [[Firefeed alloc] initWithUrl:kWilddogRoot delegate:self];
        self.currentlyEditing = NONE;
    }
    return self;
}

- (UINavigationItem *) navigationItem {
    UINavigationItem* item = [super navigationItem];
    UIBarButtonItem* logoutBtn = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    item.rightBarButtonItem = logoutBtn;
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 44.0f)];
    titleLabel.text = @"Profile";
    titleLabel.textColor = self.brownColor;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    item.titleView = titleLabel;
    return item;
}

- (void) showLoggedInUI {

    [self.bioEdit setupAsYellowButton];
    [self.locationEdit setupAsYellowButton];
    [self updateUserDetails];
    [self.bioEdit addTarget:self action:@selector(composeBio) forControlEvents:UIControlEventTouchUpInside];
    [self.locationEdit addTarget:self action:@selector(composeLocation) forControlEvents:UIControlEventTouchUpInside];
}

- (void) viewWillAppear:(BOOL)animated {
    CGRect viewFrame = self.view.frame;

    if (!CGRectEqualToRect(self.view.frame, self.scrollView.frame)) {
        [self resizeViews];
    }

    CGRect textFrame = self.aboutText.frame;
    CGFloat aboutBottom = textFrame.origin.y + textFrame.size.height;

    CGSize scrollSize = CGSizeMake(viewFrame.size.width, MAX(viewFrame.size.height, aboutBottom + 5.0f));
    self.scrollView.contentSize = scrollSize;
}

- (void) logout {
    // Log out was pressed, log out of firefeed
    [self.firefeed logout];
}

- (void) updateUserDetails {
    self.bioText.text = self.user.bio;
    self.locationText.text = self.user.location;
}

- (void) composeBio {
    ComposeViewController* composer = [[ComposeViewController alloc] init];
    composer.delegate = self;
    self.currentlyEditing = BIO;
    [composer presentFromRootViewControllerWithText:self.user.bio submitButtonTitle:@"Save" headerTitle:@"Edit Bio" characterLimit:141];
}

- (void) composeLocation {
    ComposeViewController* composer = [[ComposeViewController alloc] init];
    composer.delegate = self;
    self.currentlyEditing = LOCATION;
    [composer presentFromRootViewControllerWithText:self.user.location submitButtonTitle:@"Save" headerTitle:@"Edit Location" characterLimit:80];
}

- (void) composeViewController:(ComposeViewController *)composeViewController didFinishWithText:(NSString *)text {

    if (text != nil) {
        if (self.currentlyEditing == BIO) {
            self.user.bio = text;
        } else if (self.currentlyEditing == LOCATION) {
            self.user.location = text;
        }
        // Save any updates that were made. 
        [self.firefeed saveUser:self.user];
    }
    [composeViewController dismissViewControllerAnimated:YES completion:nil];
    self.currentlyEditing = NONE;
}

- (void) showLoggedOutUI {
    self.tabBarController.selectedIndex = 2;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    CGRect viewFrame = self.view.frame;

    self.scrollView.frame = viewFrame;

    CGRect locationTextFrame = self.locationText.frame;
    CGFloat locationBottom = locationTextFrame.origin.y + locationTextFrame.size.height;
    CGRect lineRect = CGRectMake(0, locationBottom + 15, self.view.frame.size.width, 1.0f);
    self.lineView = [[UIView alloc] initWithFrame:lineRect];
    self.lineView.backgroundColor = self.brownColor;
    [self.scrollView addSubview:self.lineView];

    [self resizeViews];
    [self showLoggedInUI];
}

- (void) resizeViews {
    self.scrollView.frame = self.view.frame;

    CGRect lineFrame = self.lineView.frame;
    lineFrame.size.width = self.view.frame.size.width;
    self.lineView.frame = lineFrame;

    CGRect locationTextFrame = self.locationText.frame;
    CGFloat locationBottom = locationTextFrame.origin.y + locationTextFrame.size.height;
    CGRect aboutRect = self.aboutLabel.frame;
    aboutRect.origin.y = locationBottom + 26;
    self.aboutLabel.frame = aboutRect;

    CGRect textFrame = self.aboutText.frame;
    textFrame.size.width = self.view.frame.size.width - 12;
    self.aboutText.frame = textFrame;
    [self.aboutText sizeToFit];
    textFrame = self.aboutText.frame;
    textFrame.origin.y = aboutRect.origin.y + aboutRect.size.height;
    self.aboutText.frame = textFrame;
}

- (void) loginStateDidChange:(FirefeedUser *)user {
    if (user) {
        self.user = user;
    } else {
        self.user = nil;
        [self showLoggedOutUI];
    }
}

- (void) userDidUpdate:(FirefeedUser *)user {
    [self updateUserDetails];
}

// No-ops

- (void) spark:(FirefeedSpark *)spark wasAddedToTimeline:(NSString *)timeline {

}

- (void) spark:(FirefeedSpark *)spark wasOverflowedFromTimeline:(NSString *)timeline {

}

- (void) spark:(FirefeedSpark *)spark wasRemovedFromTimeline:(NSString *)timeline {

}

- (void) spark:(FirefeedSpark *)spark wasUpdatedInTimeline:(NSString *)timeline {
    
}

- (void) follower:(FirefeedUser *)follower startedFollowing:(FirefeedUser *)followee {

}

- (void) follower:(FirefeedUser *)follower stoppedFollowing:(FirefeedUser *)followee {
    
}

- (void) timelineDidLoad:(NSString *)feedId {
    
}

- (void) followersDidLoad:(NSString *)userId {

}

- (void) followeesDidLoad:(NSString *)userId {
    
}

- (void) loginAttemptDidFail {
    
}

@end
