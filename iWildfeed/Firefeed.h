//
//  Firefeed.h
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirefeedUser.h"
#import "FirefeedSpark.h"
#import "FirefeedSearch.h"

@protocol FirefeedDelegate;

@interface Firefeed : NSObject

+ (void) logDiagnostics;

- (id)initWithUrl:(NSString *)rootUrl delegate:(id)delegate;

- (id) initWithUrl:(NSString *)rootUrl;
- (void) login;
- (void) logout;
- (NSString *) observeLatestSparks;
- (NSString *) observeLoggedInUserTimeline;
- (NSString *) observeSparksForUser:(NSString *)userId;
- (void) stopObservingTimeline:(NSString *)timeline;
- (void) postSpark:(NSString *)text completionBlock:(void (^)(NSError* err))block;
- (void) observeUserInfo:(NSString *)userId;
- (void) observeFollowersForUser:(NSString *)userId;
- (void) observeFolloweesForUser:(NSString *)userId;
- (void) startFollowingUser:(NSString *)userId;
- (void) stopFollowingUser:(NSString *)userId;
- (void) saveUser:(FirefeedUser *)user;
- (void) cleanup;

- (FirefeedSearch *) searchAdapter;

// Debugging
- (void) logListens;
//- (void) cleanupUsers;

@property (weak, nonatomic) id <FirefeedDelegate> delegate;

@end

@protocol FirefeedDelegate <NSObject>

- (void) loginStateDidChange:(FirefeedUser *)user;
- (void) loginAttemptDidFail;
- (void) spark:(FirefeedSpark *)spark wasAddedToTimeline:(NSString *)timeline;
- (void) spark:(FirefeedSpark *)spark wasOverflowedFromTimeline:(NSString *)timeline;
- (void) spark:(FirefeedSpark *)spark wasUpdatedInTimeline:(NSString *)timeline;
- (void) spark:(FirefeedSpark *)spark wasRemovedFromTimeline:(NSString *)timeline;
- (void) follower:(FirefeedUser *)follower startedFollowing:(FirefeedUser *)followee;
- (void) follower:(FirefeedUser *)follower stoppedFollowing:(FirefeedUser *)followee;
- (void) userDidUpdate:(FirefeedUser *)user;
- (void) timelineDidLoad:(NSString *)feedId;
- (void) followersDidLoad:(NSString *)userId;
- (void) followeesDidLoad:(NSString *)userId;

@end
