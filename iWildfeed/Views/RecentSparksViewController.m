//
//  RecentSparksViewController.m
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "RecentSparksViewController.h"
#import "UserSearchViewController.h"

@implementation RecentSparksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Recent Sparks" image:[UIImage imageNamed:@"recent.png"] tag:0];
    }
    return self;
}


- (void) showLoggedOutUI {
    UIBarButtonItem* loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(tryLogin)];
    self.navigationItem.rightBarButtonItem = loginButton;
    self.navigationItem.leftBarButtonItem = [self leftBarButton];
    [[self.tabBarController.tabBar.items objectAtIndex:0] setEnabled:NO];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setEnabled:NO];
    self.currentFeedId = [self.firefeed observeLatestSparks];
}

- (UIBarButtonItem *) leftBarButton {
    return [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(startSearch)];
}

- (void) showLoggedInUI {
    [super showLoggedInUI];
    self.currentFeedId = [self.firefeed observeLatestSparks];
}


- (void) tryLogin {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.firefeed login];
}

- (void) loginAttemptDidFail {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (NSString *) title {
    return @"Recent";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
