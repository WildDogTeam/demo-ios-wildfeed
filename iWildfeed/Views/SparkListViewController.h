//
//  SparkListViewController.h
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firefeed.h"

@interface SparkListViewController : UIViewController

- (void) startComposing;
- (void) startSearch;
- (void) logout;
// Override this
- (NSString *) title;

- (void) showLoggedInUI;
- (void) showLoggedOutUI;

- (void) userDidUpdate:(FirefeedUser *)user;

@property (strong, nonatomic) Firefeed* firefeed;
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) NSString* currentFeedId;

@end
