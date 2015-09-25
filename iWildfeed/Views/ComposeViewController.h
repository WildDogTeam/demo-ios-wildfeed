//
//  ComposeViewController.h
//  iFirefeed
//
//  Created by IMacLi on 4/3/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ComposeViewControllerDelegate;

@interface ComposeViewController : UIViewController

- (void) presentFromRootViewControllerWithText:(NSString *)text submitButtonTitle:(NSString *)title headerTitle:(NSString *)headerTitle characterLimit:(NSInteger)charLimit;

@property (weak, nonatomic) id<ComposeViewControllerDelegate> delegate;

@end

@protocol ComposeViewControllerDelegate <NSObject>

- (void)composeViewController:(ComposeViewController *)composeViewController didFinishWithText:(NSString *)text;

@end