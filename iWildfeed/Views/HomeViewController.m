//
//  HomeViewController.m
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "HomeViewController.h"
#import "ComposeViewController.h"
#import "ProfileViewController.h"
#import "Firefeed.h"
#import "SparkCell.h"
#import "UserSearchViewController.h"


@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"logo-32.png"] tag:0];
    }
    return self;
}

- (NSString *) title {
    return @"Home";
}

- (void) showLoggedInUI {
    [super showLoggedInUI];
    self.currentFeedId = [self.firefeed observeLoggedInUserTimeline];
}

- (void) showLoggedOutUI {
    self.tabBarController.selectedIndex = 2;
}

- (void) tryLogin {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.firefeed login];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarButtonItem *) leftBarButton {
    return [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(startSearch)];
}


@end
