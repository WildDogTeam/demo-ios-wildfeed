//
//  NSMutableArray+Sorted.h
//  iFirefeed
//
//  Created by IMacLi on 5/3/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>

// Add a basic sorting function to NSMutableArray
@interface NSMutableArray (Sorted)

- (void) insertSorted:(id)newObject;

@end
