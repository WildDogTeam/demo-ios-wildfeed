//
//  ComposeTextView.m
//  iFirefeed
//
//  Created by IMacLi on 4/3/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "ComposeTextView.h"
#import "ComposeRuledView.h"

@interface ComposeTextView ()

@property (retain, nonatomic) ComposeRuledView* ruledView;

@end

@implementation ComposeTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        _ruledView = [[ComposeRuledView alloc] initWithFrame:[self ruledViewFrame]];
        _ruledView.lineColor = [UIColor colorWithRed:0x7b / 255.0f green:0x5f / 255.0f blue:0x11 / 255.0f alpha:0.25f];
        _ruledView.lineWidth = 1.0f;
        _ruledView.rowHeight = self.font.lineHeight + 12;
        [self insertSubview:self.ruledView atIndex:0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.ruledView.frame = [self ruledViewFrame];
}

- (CGRect)ruledViewFrame {
    CGFloat extraForBounce = 200.0f;  // Extra added to top and bottom so it's visible when the user drags past the bounds.
    CGFloat width = 1024.0f;  // Needs to be at least as wide as we might make the Tweet sheet.
    CGFloat textAlignmentOffset = -11.0f;  // To center the text between the lines. May want to find a way to determine this procedurally eventually.

    CGRect frame;

    frame = CGRectMake(0.0f, -extraForBounce + textAlignmentOffset, width, self.contentSize.height + (2 * extraForBounce));

    return frame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
