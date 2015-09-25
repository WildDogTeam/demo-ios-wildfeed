//
//  UserSearchViewController.h
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirefeedSearch.h"

@protocol UserSearchDelegate;

@interface UserSearchViewController : UIViewController

@property (strong, nonatomic) FirefeedSearch* firefeedSearch;
@property (weak, nonatomic) id<UserSearchDelegate> delegate;

@end

@protocol UserSearchDelegate

- (void) userWasSelected:(NSString *)userId;
- (void) searchWasCancelled;

@end