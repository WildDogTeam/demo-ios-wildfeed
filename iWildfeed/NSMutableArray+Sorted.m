//
//  NSMutableArray+Sorted.m
//  iFirefeed
//
//  Created by IMacLi on 5/3/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "NSMutableArray+Sorted.h"

@implementation NSMutableArray (Sorted)

- (void) insertSorted:(id)newObject {
    [self insertObject:newObject betweenLower:0 andUpper:self.count];
}

/**
 * Performs a binary search for the correct insert location
 */
- (void) insertObject:(id)newObject betweenLower:(NSInteger)lower andUpper:(NSInteger)upper {
    if (lower == upper) {
        [self insertObject:newObject atIndex:lower];
    } else {
        NSInteger middle = (upper - lower) / 2 + lower;
        NSComparisonResult result = [newObject compare:[self objectAtIndex:middle]];
        if (result == NSOrderedAscending) {
            [self insertObject:newObject betweenLower:lower andUpper:middle];
        } else if (result == NSOrderedSame) {
            [self insertObject:newObject atIndex:middle];
        } else {
            [self insertObject:newObject betweenLower:middle + 1 andUpper:upper];
        }
    }
}

@end
