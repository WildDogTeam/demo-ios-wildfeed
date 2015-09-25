//
//  ComposeSheetView.h
//  iFirefeed
//
//  Created by IMacLi on 4/3/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeTextView.h"

@protocol ComposeSheetViewDelegate;

@interface ComposeSheetView : UIView <UITextViewDelegate>

- (void) setSubmitTitle:(NSString *)title;
- (void) setInitialText:(NSString *)text;
- (void) setHeaderTitle:(NSString *)title;

@property (nonatomic) NSInteger charLimit;
@property (readonly, nonatomic) UINavigationItem *navigationItem;
@property (readonly, nonatomic) UINavigationBar *navigationBar;
@property (readonly, nonatomic) UIView *textViewContainer;
@property (readonly, nonatomic) ComposeTextView *textView;
@property (weak, nonatomic) UIViewController<ComposeSheetViewDelegate>* delegate;

@end

@protocol ComposeSheetViewDelegate <NSObject>

- (void)cancelButtonPressed;
- (void)postButtonPressed;

@end