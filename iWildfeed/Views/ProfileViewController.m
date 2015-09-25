//
//  ProfileViewController.m
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "ProfileViewController.h"
#import "SparkCell.h"
#import "UserCell.h"
#import "UIImageView+WebCache.h"
#import "FirefeedAuth.h"
#import "NSMutableArray+Sorted.h"

@interface ProfileViewController () <FirefeedDelegate, UITabBarDelegate, UITableViewDelegate>

@property (strong, nonatomic) Firefeed* firefeed;
@property (strong, nonatomic) NSString* sparkFeedId;
@property (strong, nonatomic) NSMutableArray* sparks;
@property (strong, nonatomic) NSMutableArray* followers;
@property (strong, nonatomic) NSMutableArray* following;
@property (strong, nonatomic) NSString* loggedInUserId;
@property (strong, nonatomic) UIColor* brown;
@property (strong, nonatomic) UIColor* yellow;
@property (strong, nonatomic) UIActivityIndicatorView* spinner;
@property (nonatomic) BOOL sparksLoaded;
@property (nonatomic) BOOL followersLoaded;
@property (nonatomic) BOOL followeesLoaded;

@end

#define SPARKS_TAB 0
#define FOLLOWERS_TAB 1
#define FOLLOWING_TAB 2

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sparksLoaded = NO;
        self.followeesLoaded = NO;
        self.followersLoaded = NO;
        self.firefeed = [[Firefeed alloc] initWithUrl:kWilddogRoot];
        self.sparks = [[NSMutableArray alloc] init];
        self.followers = [[NSMutableArray alloc] init];
        self.following = [[NSMutableArray alloc] init];
        self.firefeed.delegate = self;
        self.brown = [UIColor colorWithRed:0x7b / 255.0f green:0x5f / 255.0f blue:0x11 / 255.0f alpha:1.0f];
        self.yellow = [UIColor colorWithRed:0xff / 255.0f green:0xea / 255.0f blue:0xb3 / 255.0f alpha:1.0];
    }
    return self;
}

- (void) dealloc {
    // Make sure we cleanup our listeners when this goes away to prevent memory leaks
    [self.firefeed cleanup];
}

- (void) viewWillAppear:(BOOL)animated {

    CGRect segmentFrame = self.segmentedControl.frame;
    CGRect picFrame = CGRectMake(6, 32, 96, 96);
    self.profileImage.frame = picFrame;
    segmentFrame.size.height = 26;
    segmentFrame.size.width = self.view.frame.size.width - 12;
    segmentFrame.origin.y = picFrame.origin.y + picFrame.size.height + 6;
    self.segmentedControl.frame = segmentFrame;
    CGFloat tableTop = segmentFrame.origin.y + segmentFrame.size.height + 3;
    CGRect tabBarFrame = self.tabBarController.tabBar.frame;
    CGRect navFrame = self.navigationController.navigationBar.frame;
    CGFloat tableHeight = (tabBarFrame.origin.y - navFrame.size.height) - tableTop - 20;
    CGRect tableFrame = CGRectMake(0, tableTop, self.view.frame.size.width, tableHeight);
    self.tableView.frame = tableFrame;

    CGRect btnFrame = self.actionButton.frame;
    btnFrame.origin.x = self.view.frame.size.width - btnFrame.size.width - 6;
    self.actionButton.frame = btnFrame;
    

    CGRect frame = self.view.frame;
    CGRect spinnerFrame = CGRectMake(frame.size.width / 2 - 100, frame.size.height / 2 - 100, 200, 200);
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.color = self.brown;
    self.spinner.frame = spinnerFrame;

    [self highlightSelectedSegment];
}

- (void) viewDidAppear:(BOOL)animated {
    [self highlightSelectedSegment];
}


- (void) actionButtonWasPressed {
    // Handles the follow / unfollow button
    if (self.loggedInUserId) {
        if ([self.userId isEqualToString:self.loggedInUserId]) {
            // no-op, shouldn't show
        } else if ([self loggedInUserIsFollowingUser]) {
            [self.firefeed stopFollowingUser:self.userId];
        } else {
            [self.firefeed startFollowingUser:self.userId];
        }
    }
}

- (UINavigationItem *) navigationItem {
    UINavigationItem* item = [super navigationItem];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 44.0f)];
    titleLabel.text = @"Profile";
    titleLabel.textColor = self.brown;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    item.titleView = titleLabel;
    return item;
}

- (void) refreshSpinner {
    if (self.segmentedControl.selectedSegmentIndex == SPARKS_TAB) {
        if (self.sparksLoaded && self.spinner.superview) {
            [self.spinner stopAnimating];
            [self.spinner removeFromSuperview];
        } else if (!self.sparksLoaded && !self.spinner.superview) {
            [self.view addSubview:self.spinner];
            [self.spinner startAnimating];
        }
    } else if (self.segmentedControl.selectedSegmentIndex == FOLLOWERS_TAB) {
        if (self.followersLoaded && self.spinner.superview) {
            [self.spinner stopAnimating];
            [self.spinner removeFromSuperview];
        } else if (!self.followersLoaded && !self.spinner.superview) {
            [self.view addSubview:self.spinner];
            [self.spinner startAnimating];
        }
    } else {
        if (self.followeesLoaded && self.spinner.superview) {
            [self.spinner stopAnimating];
            [self.spinner removeFromSuperview];
        } else if (!self.followeesLoaded && !self.spinner.superview) {
            [self.view addSubview:self.spinner];
            [self.spinner startAnimating];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nameLabel.frame = CGRectMake(6, 6, 220, 21);
    self.profileImage.image = [UIImage imageNamed:@"placekitten_large.png"];
    self.bioTextView.text = @"No bio";
    self.bioTextView.textColor = [UIColor grayColor];

    self.locationText.text = @"No location";
    self.locationText.textColor = [UIColor grayColor];

    self.bioTextView.frame = CGRectMake(104, 32, 216, 74);
    self.bioTextView.contentInset = UIEdgeInsetsMake(-9, -3, 0, 0);

    self.locationText.frame = CGRectMake(104, 100, 206, 32);
    self.locationText.contentInset = UIEdgeInsetsMake(-9, -3, 0, 0);

    [self.segmentedControl addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventValueChanged];

    self.sparkFeedId = [self.firefeed observeSparksForUser:self.userId];

    [self.actionButton setupAsYellowButton];
    [self.actionButton setAlpha:0];
    [self.actionButton addTarget:self action:@selector(actionButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];

    [self.firefeed observeUserInfo:self.userId];

    [self.firefeed observeFollowersForUser:self.userId];
    [self.firefeed observeFolloweesForUser:self.userId];
    self.tableView.separatorColor = self.brown;
    self.tableView.rowHeight = 72.0f;
}

- (void) userDidUpdate:(FirefeedUser *)user {
    [self refreshUserData:user];
}

- (void) refreshUserData:(FirefeedUser *)user {
    // handle an update to this user's data.
    [self.profileImage sd_setImageWithURL:user.picUrl placeholderImage:[UIImage imageNamed:@"placekitten_large.png"]];
    self.nameLabel.text = user.fullName;
    NSString* bio = user.bio;
    if (bio && ![bio isEqualToString:@""]) {
        self.bioTextView.text = bio;
        self.bioTextView.textColor = [UIColor blackColor];
    }

    NSString* location = user.location;
    if (location && ![location isEqualToString:@""]) {
        self.locationText.text = location;
        self.locationText.textColor = [UIColor blackColor];
    }
}

- (void) highlightSelectedSegment {
    for (int i = 0; i < self.segmentedControl.subviews.count; ++i) {
        BOOL selected = [[self.segmentedControl.subviews objectAtIndex:i] isSelected];

        UIColor* tintColor = selected ? self.yellow : self.brown;
        UIColor* textColor = selected ? self.brown : [UIColor whiteColor];

        [[self.segmentedControl.subviews objectAtIndex:i] setTintColor:tintColor];
        UIView* segment = [self.segmentedControl.subviews objectAtIndex:i];
        for (UIView* subView in segment.subviews) {
            if ([subView isKindOfClass:[UILabel class]]) {
                ((UILabel *)subView).textColor = textColor;
                ((UILabel *)subView).shadowColor = [UIColor clearColor];
            }
        }
    }
    [self refreshSpinner];
}

- (void) segmentSelected:(id)sender {
    [self highlightSelectedSegment];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginStateDidChange:(FirefeedUser *)user {
    if (!user) {
        self.actionButton.alpha = 0.0;
        self.loggedInUserId = nil;
    } else {
        self.loggedInUserId = user.userId;
    }
    [self refreshActionButton];
}

- (void) refreshActionButton {
    if (self.followersLoaded && self.loggedInUserId && ![self.loggedInUserId isEqualToString:self.userId]) {
        if ([self loggedInUserIsFollowingUser]) {
            [self.actionButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        } else {
            [self.actionButton setTitle:@"Follow" forState:UIControlStateNormal];
        }
        self.actionButton.alpha = 1.0;
    } else {
        self.actionButton.alpha = 0.0;
    }
}

// The next few methods manage changes in the table of sparks for this user.
// We don't worry about sparks being overflowed, we'll still keep them in the table, they just won't continue to update
- (void) spark:(NSDictionary *)spark wasAddedToTimeline:(NSString *)timeline {
    [self.sparks insertSorted:spark];
    if (self.segmentedControl.selectedSegmentIndex == SPARKS_TAB) {
        [self.tableView reloadData];
    }
}

- (void) spark:(FirefeedSpark *)spark wasRemovedFromTimeline:(NSString *)timeline {
    [self.sparks removeObject:spark];
    if (self.segmentedControl.selectedSegmentIndex == SPARKS_TAB) {
        [self.tableView reloadData];
    }
}

- (void) spark:(FirefeedSpark *)spark wasUpdatedInTimeline:(NSString *)timeline {
    if (self.segmentedControl.selectedSegmentIndex == SPARKS_TAB) {
        [self.tableView reloadData];
    }
}

- (void) spark:(NSDictionary *)spark wasOverflowedFromTimeline:(NSString *)timeline {
    
}


// Manage the table of followers and followees for this user
// After each change, update the action button, since the logged in user may have start or stopped following this user
- (void) follower:(FirefeedUser *)follower startedFollowing:(FirefeedUser *)followee {
    NSInteger selected = self.segmentedControl.selectedSegmentIndex;
    if ([followee.userId isEqualToString:self.userId]) {
        [self.followers addObject:follower];

        if (selected == FOLLOWERS_TAB) {
            [self.tableView reloadData];
        }
    } else if ([follower.userId isEqualToString:self.userId]) {
        [self.following addObject:followee];

        if (selected == FOLLOWING_TAB) {
            [self.tableView reloadData];
        }
    }
    [self refreshActionButton];
}

- (void) follower:(FirefeedUser *)follower stoppedFollowing:(FirefeedUser *)followee {
    if ([followee.userId isEqualToString:self.userId]) {
        if ([self.followers containsObject:follower]) {
            [self.followers removeObject:follower];
            [self.tableView reloadData];
            [self refreshActionButton];
        }
    } else if ([follower.userId isEqualToString:self.userId]) {
        if ([self.following containsObject:followee]) {
            [self.following removeObject:followee];
            [self.tableView reloadData];
            [self refreshActionButton];
        }
    }
}


- (BOOL) loggedInUserIsFollowingUser {
    for (FirefeedUser* follower in self.followers) {
        if ([self.loggedInUserId isEqualToString:follower.userId]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    NSInteger selected = self.segmentedControl.selectedSegmentIndex;
    if (selected == SPARKS_TAB) {
        return self.sparks.count;
    } else if (selected == FOLLOWERS_TAB) {
        return self.followers.count;
    } else {
        return self.following.count;
    }
}

- (void) showProfileForRow:(NSInteger)index {
    // Bind a user to an entry in the table
    NSInteger selected = self.segmentedControl.selectedSegmentIndex;
    if (selected == FOLLOWERS_TAB) {
        FirefeedUser* user = [self.followers objectAtIndex:(self.followers.count - index - 1)];
        ProfileViewController* profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        profileViewController.userId = user.userId;
        UIViewController* rootViewController = [self.navigationController.viewControllers objectAtIndex:0];
        NSArray* controllers = @[rootViewController, profileViewController];
        [self.navigationController setViewControllers:controllers animated:YES];
    } else if (selected == FOLLOWING_TAB) {
        FirefeedUser* user = [self.following objectAtIndex:(self.following.count - index - 1)];
        ProfileViewController* profileViewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        profileViewController.userId = user.userId;
        UIViewController* rootViewController = [self.navigationController.viewControllers objectAtIndex:0];
        NSArray* controllers = @[rootViewController, profileViewController];
        [self.navigationController setViewControllers:controllers animated:YES];
    }
}

// Create table cells for followers
- (UITableViewCell *) followerCellForRow:(NSInteger)row {
    static NSString *CellIdentifier = @"UserCell";

    UserCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    FirefeedUser* follower = [self.followers objectAtIndex:(self.followers.count - row - 1)];
    [cell configureForUser:follower];

    return cell;
}

// Create table cells for followees
- (UITableViewCell *) followeeCellForRow:(NSInteger)row {
    static NSString *CellIdentifier = @"UserCell";

    UserCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        NSArray* nib = [[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    FirefeedUser* followee = [self.following objectAtIndex:(self.following.count - row - 1)];
    [cell configureForUser:followee];
    return cell;
}

// Create table cells for sparks
- (UITableViewCell *) sparkCellForRow:(NSInteger)row {
    static NSString *CellIdentifier = @"ProfileSparkCell";

    SparkCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        NSArray *nib =  [[NSBundle mainBundle] loadNibNamed:@"SparkCell" owner:self options: nil];
        cell = [nib objectAtIndex:0];
    }

    // Put in reverse order
    FirefeedSpark* spark = [self.sparks objectAtIndex:(self.sparks.count - row - 1)];
    [cell configureForSpark:spark];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger selected = self.segmentedControl.selectedSegmentIndex;
    if (selected == SPARKS_TAB) {
        // No-op, we're already on the profile page
    } else {
        [self showProfileForRow:indexPath.row];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger selected = self.segmentedControl.selectedSegmentIndex;
    if (selected == SPARKS_TAB) {
        return [self sparkCellForRow:indexPath.row];
    } else if (selected == FOLLOWERS_TAB) {
        return [self followerCellForRow:indexPath.row];
    } else {
        return [self followeeCellForRow:indexPath.row];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72.0f;
}

- (void) timelineDidLoad:(NSString *)feedId {
    self.sparksLoaded = YES;
}

- (void) followeesDidLoad:(NSString *)userId {
    self.followeesLoaded = YES;
}

- (void) followersDidLoad:(NSString *)userId {
    self.followersLoaded = YES;
    [self refreshActionButton];
}

- (void) loginAttemptDidFail {
    // No-op
}

@end
