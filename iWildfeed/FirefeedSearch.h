//
//  FirefeedSearch.h
//  iFirefeed
//
//  Created by IMacLi on 4/23/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Wilddog/Wilddog.h>

@protocol FirefeedSearchDelegate;

@interface FirefeedSearch : NSObject

- (id) initWithRef:(Wilddog *)ref;

- (BOOL) searchTextDidUpdate:(NSString *)text;

@property (strong, nonatomic) UITableView* resultsTable;
@property (weak, nonatomic) id<FirefeedSearchDelegate> delegate;

@end

@protocol FirefeedSearchDelegate <NSObject>

- (void) userIdWasSelected:(NSString *)userId;

@end