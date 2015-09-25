//
//  ComposeSheetView.m
//  iFirefeed
//
//  Created by IMacLi on 4/3/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "ComposeSheetView.h"

@implementation ComposeSheetView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        // Setup the nav bar
        _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth
        | UIViewAutoresizingFlexibleBottomMargin
        | UIViewAutoresizingFlexibleRightMargin;

        _navigationItem = [[UINavigationItem alloc] initWithTitle:@"Set Me"];
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 44.0f)];
        titleLabel.text = @"Set me";
        titleLabel.textColor = [UIColor colorWithRed:0x7b / 255.0f green:0x5f / 255.0f blue:0x11 / 255.0f alpha:1.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        _navigationItem.titleView = titleLabel;
         
        _navigationBar.items = @[_navigationItem];

        UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed)];
        _navigationItem.leftBarButtonItem = cancelButtonItem;

        UIBarButtonItem *postButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Set me" style:UIBarButtonItemStyleBordered target:self action:@selector(postButtonPressed)];
        _navigationItem.rightBarButtonItem = postButtonItem;


        _textViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height - 44)];
        _textViewContainer.clipsToBounds = YES;
        _textViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _textView = [[ComposeTextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 47)];
        _textView.backgroundColor = [UIColor colorWithRed:1.0f green:252.0f / 255.0f blue:244.0f / 255.0f alpha:1.0f];
        _textView.font = [UIFont systemFontOfSize:21];
        _textView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
        _textView.bounces = YES;
        _textView.delegate = self;
        [_textViewContainer addSubview:_textView];
        [self addSubview:_textViewContainer];
        
        [self addSubview:_navigationBar];
    }
    return self;
}

- (void) setHeaderTitle:(NSString *)title {
    ((UILabel *)(_navigationItem.titleView)).text = title;
}

- (void) setSubmitTitle:(NSString *)title {
    _navigationItem.rightBarButtonItem.title = title;
}

- (void) setInitialText:(NSString *)text {
    _textView.text = text;
}

- (void) cancelButtonPressed {
    [self.delegate cancelButtonPressed];
}

- (void) postButtonPressed {
    [self.delegate postButtonPressed];
}


- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // "Length of existing text" - "Length of replaced text" + "Length of replacement text"
    NSInteger newTextLength = [aTextView.text length] - range.length + [text length];

    if (newTextLength > self.charLimit) {
        // don't allow change
        return NO;
    }
    //countLabel.text = [NSString stringWithFormat:@"%i", newTextLength];
    return YES;
}

@end
