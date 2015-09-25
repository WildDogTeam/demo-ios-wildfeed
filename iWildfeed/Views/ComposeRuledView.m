//
//  ComposeRuledView.m
//  iFirefeed
//
//  Created by IMacLi on 4/3/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "ComposeRuledView.h"

@implementation ComposeRuledView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        self.userInteractionEnabled = NO;

        _rowHeight = 20.0f;
        _lineWidth = 1.0f;
        //_lineColor = [UIColor colorWithWhite:0.5f alpha:0.15f];
        _lineColor = [UIColor colorWithRed:0x7b / 255.0f green:0x5f / 255.0f blue:0x11 / 255.0f alpha:1.0f];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    CGFloat strokeOffset = (self.lineWidth / 2);  // Because lines are drawn between pixels. This moves it back onto the pixel.

    if (self.rowHeight > 0.0f) {
        CGRect rowRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, self.rowHeight);
        NSInteger rowNumber = 1;
        while (rowRect.origin.y < self.frame.size.height + 100.0f) {
            CGContextMoveToPoint(context, rowRect.origin.x + strokeOffset, rowRect.origin.y + strokeOffset);
            CGContextAddLineToPoint(context, rowRect.origin.x + rowRect.size.width + strokeOffset, rowRect.origin.y + strokeOffset);
            CGContextDrawPath(context, kCGPathStroke);

            rowRect.origin.y += self.rowHeight;
            rowNumber++;
        }
    }
}

@end
