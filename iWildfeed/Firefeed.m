//
//  Firefeed.m
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "Firefeed.h"
#import <Wilddog/Wilddog.h>
#import "FirefeedAuth.h"
#import "FirefeedSpark.h"

typedef void (^ffbt_void_nserror)(NSError* err);
typedef void (^ffbt_void_nserror_dict)(NSError* err, NSDictionary* dict);

@interface FeedHandlers : NSObject

@property (nonatomic) WilddogHandle childAddedHandle;
@property (nonatomic) WilddogHandle childRemovedHandle;
@property (strong, nonatomic) FirefeedUser* user;
@property (strong, nonatomic) Wilddog* ref;

@end

@implementation FeedHandlers


@end

@interface Firefeed () <FirefeedUserDelegate>

@property (strong, nonatomic) Wilddog* root;
@property (strong, nonatomic) NSMutableDictionary* feeds;
@property (strong, nonatomic) NSMutableArray* users;
@property (strong, nonatomic) NSMutableArray* sparks;
@property (nonatomic) long serverTimeOffset;
@property (nonatomic) WilddogHandle timeOffsetHandle;
@property (strong, nonatomic) FirefeedUser* loggedInUser;
@property (strong, nonatomic) Wilddog* userRef;

@end

@implementation Firefeed

- (void)setDelegate:(id<FirefeedDelegate>)delegate
{
    if (delegate == nil) {
        
    }
    
    if ([delegate isMemberOfClass:[NSObject class]]) {
        
    }
    
    
    _delegate = delegate;
}

+ (void) logDiagnostics {
    // Quick dump of some relevant info about the app
    NSLog(@"Running w/ wilddog %@", [Wilddog sdkVersion]);
    NSLog(@"bundle id: %@", [NSBundle mainBundle].bundleIdentifier);
}



- (id)initWithUrl:(NSString *)rootUrl delegate:(id)delegate
{
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
        self.root = [[Wilddog alloc] initWithUrl:rootUrl];
        
        __weak Firefeed* weakSelf = self;
        // Get an idea of what the actual time is from the wilddog servers
        //        self.timeOffsetHandle = [[self.root childByAppendingPath:@".info/serverTimeOffset"] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        //
        //            weakSelf.serverTimeOffset = [(NSNumber *)snapshot.value longValue];
        //
        //        }];
        
        weakSelf.serverTimeOffset = -47;
        self.serverTimeOffset = 0;
        
        // Auth handled via a global singleton. Prevents modules squashing eachother
        [FirefeedAuth watchAuthForRef:self.root withBlock:^(NSError *error, WAuthData *user) {
            if (error) {
                
                NSLog(@"AUTHENTICATION ERROR: %@", error);
                [weakSelf.delegate loginAttemptDidFail];
                
            } else {
                
                [weakSelf onAuthStatus:user];
                
            }
        }];
        
        
        self.feeds = [[NSMutableDictionary alloc] init];
        self.users = [[NSMutableArray alloc] init];
        self.sparks = [[NSMutableArray alloc] init];
        
        
    }
    
    
    return self;

}


- (id) initWithUrl:(NSString *)rootUrl {
    
    return [self initWithUrl:rootUrl delegate:nil];
}



- (void) dealloc {
    // Stop watching the time offset so we don't leak memory
    
    [[self.root childByAppendingPath:@".info/serverTimeOffset"] removeObserverWithHandle:_timeOffsetHandle];
    
}

- (void) cleanup {
    // Clean up all of our listeners so we don't leak memory
    for (NSString* url in self.feeds) {
        FeedHandlers* handle = [self.feeds objectForKey:url];
        [self stopObservingFeed:handle];
    }
    [self.feeds removeAllObjects];
    [self stopObservingLoginStatus];
    [self cleanupUsers];
    [self cleanupSparks];
}

- (void) stopObservingFeed:(FeedHandlers *)handle {
    // We track two separate events, and possibly a user as well. Remove all the listeners
    [handle.ref removeObserverWithHandle:handle.childAddedHandle];
    [handle.ref removeObserverWithHandle:handle.childRemovedHandle];
    if (handle.user) {
        [handle.user stopObserving];
    }
}

- (void) stopObservingLoginStatus {
    // If we were logged in, remove the listener for auth status
    if (self.loggedInUser) {
        [self.loggedInUser stopObserving];
        self.loggedInUser = nil;
    }
}

- (void) cleanupUsers {
    // Remove listeners for all of the users we're watching
    for (FirefeedUser* user in self.users) {
        [user stopObserving];
    }
    [self.users removeAllObjects];
}

- (void) cleanupSparks {
    // Remove listeners for all of the sparks we're watching
    for (FirefeedSpark* spark in self.sparks) {
        [spark stopObserving];
    }
    [self.sparks removeAllObjects];
}

- (void) logListens {
    // Debug method. See what data we're observing
    NSLog(@"Firefeed outstanding observers");
    for (NSString* key in self.feeds) {
        NSLog(@"Feed: %@", key);
    }

    for (FirefeedUser* user in self.users) {
        NSLog(@"User: %@", user);
    }
    if (self.loggedInUser) {
        NSLog(@"logged in user: %@", self.loggedInUser);
    }
    NSLog(@"End outstanding observers");
}

- (FirefeedSearch *) searchAdapter {
    return [[FirefeedSearch alloc] initWithRef:self.root];
}

- (void) login {
    [FirefeedAuth loginRef:self.root toQQAppWithId:kQQAppId];
}

- (void) logout {
    [FirefeedAuth logoutRef:self.root];
}

- (void) onAuthStatus:(WAuthData *)user {
    if (user) {
        // A user is logged in
        NSString* fullName = [user.providerData[@"cachedUserProfile"] objectForKey:@"nickname"];
        NSString* firstName = @"";
        NSString* lastName = @"";
        self.userRef = [[self.root childByAppendingPath:@"users"] childByAppendingPath:user.uid];
        // We shouldn't get this if we already have a user...
        self.loggedInUser = [FirefeedUser loadFromRoot:self.root withUserData:@{@"firstName": firstName, @"lastName": lastName,@"fullName": fullName, @"userId": user.uid} completionBlock:^(FirefeedUser *user) {
            [user updateFromRoot:self.root];
            self.loggedInUser.delegate = self;
            [self.delegate loginStateDidChange:user];
            
        }];

    } else {
        // There is no user logged in. If we had one before, remove the observers
        if (self.loggedInUser) {
            
            [self.loggedInUser stopObserving];
            
        }
        
        self.loggedInUser = nil;
        
        [self.delegate loginStateDidChange:nil];
          
        
    }
    
}

- (void) observeFolloweesForUser:(NSString *)userId {
    // This method sets up observers followees being added and removed. Each followee that is added is observed individually

    __weak Firefeed* weakSelf = self;

    [FirefeedUser loadFromRoot:self.root withUserId:userId completionBlock:^(FirefeedUser *followingUser) {
        Wilddog* ref = [[[self.root childByAppendingPath:@"users"] childByAppendingPath:userId] childByAppendingPath:@"following"];

        NSString* feedId = ref.description;
        FeedHandlers* handles = [[FeedHandlers alloc] init];
        handles.user = followingUser;
        handles.ref = ref;
        handles.childAddedHandle = [ref observeEventType:WEventTypeChildAdded withBlock:^(WDataSnapshot *snapshot) {
            if (weakSelf) {
                NSString* followerId = snapshot.key;
                FirefeedUser* user = [FirefeedUser loadFromRoot:weakSelf.root withUserId:followerId completionBlock:^(FirefeedUser *user) {
                    [weakSelf.delegate follower:followingUser startedFollowing:user];
                }];
                [weakSelf.users addObject:user];
            }
            
        }];

        handles.childRemovedHandle = [ref observeEventType:WEventTypeChildRemoved withBlock:^(WDataSnapshot *snapshot) {
            if (weakSelf) {
                NSString* followerId = snapshot.key;
                FirefeedUser* user = [FirefeedUser loadFromRoot:weakSelf.root withUserId:followerId completionBlock:^(FirefeedUser *user) {
                    [weakSelf.delegate follower:followingUser stoppedFollowing:user];
                }];
                [weakSelf.users addObject:user];
            }
        }];

        [ref observeSingleEventOfType:WEventTypeValue withBlock:^(WDataSnapshot *snapshot) {
            [weakSelf.delegate followeesDidLoad:userId];
        }];

        [self.feeds setObject:handles forKey:feedId];

    }];
}


- (void) observeFollowersForUser:(NSString *)userId {
    // This method sets up observers followers being added and removed. Each follower that is added is observed individually

    __weak Firefeed* weakSelf = self;
    [FirefeedUser loadFromRoot:self.root withUserId:userId completionBlock:^(FirefeedUser *followedUser) {
        Wilddog* ref = [[[self.root childByAppendingPath:@"users"] childByAppendingPath:userId] childByAppendingPath:@"followers"];

        NSString* feedId = ref.description;
        FeedHandlers* handles = [[FeedHandlers alloc] init];
        handles.user = followedUser;
        handles.ref = ref;
        handles.childAddedHandle = [ref observeEventType:WEventTypeChildAdded withBlock:^(WDataSnapshot *snapshot) {
            if (weakSelf) {
                NSString* followerId = snapshot.key;
                FirefeedUser* user = [FirefeedUser loadFromRoot:weakSelf.root withUserId:followerId completionBlock:^(FirefeedUser *user) {
                    [weakSelf.delegate follower:user startedFollowing:followedUser];
                }];
                [weakSelf.users addObject:user];
            }

        }];

        handles.childRemovedHandle = [ref observeEventType:WEventTypeChildRemoved withBlock:^(WDataSnapshot *snapshot) {
            if (weakSelf) {
                NSString* followerId = snapshot.key;
                FirefeedUser* user = [FirefeedUser loadFromRoot:weakSelf.root withUserId:followerId completionBlock:^(FirefeedUser *user) {
                    [weakSelf.delegate follower:user stoppedFollowing:followedUser];
                }];
                [weakSelf.users addObject:user];
            }
        }];

        [ref observeSingleEventOfType:WEventTypeValue withBlock:^(WDataSnapshot *snapshot) {
            [weakSelf.delegate followersDidLoad:userId];
        }];

        [self.feeds setObject:handles forKey:feedId];
        
    }];
}

- (NSString *) observeFeed:(Wilddog *)ref withCount:(NSUInteger)count {
   
    // Watch a limited number of sparks in a particular feed
    WQuery* query = [ref queryLimitedToLast:1];

    NSString* feedId = ref.description;
    __weak Firefeed* weakSelf = self;
    WilddogHandle childAddedHandle = [query observeEventType:WEventTypeChildAdded withBlock:^(WDataSnapshot *snapshot) {
        if (weakSelf) {
            NSString* sparkId = snapshot.key;
            __block BOOL loaded = NO;
            
            __block FirefeedSpark* outerSpark = [FirefeedSpark loadFromRoot:self.root withSparkId:sparkId block:^(FirefeedSpark* spark) {
                
                if (loaded && spark) {
                    [weakSelf.delegate spark:spark wasUpdatedInTimeline:feedId];
                } else if (!loaded && spark) {
                    loaded = YES;
                    [weakSelf.delegate spark:spark wasAddedToTimeline:feedId];
                } else if (loaded) {
                    // The spark in question was deleted.
                    [weakSelf.delegate spark:outerSpark wasRemovedFromTimeline:feedId];
                } else {
                    // The spark in question doesn't exist
                    // We can leave it alone, and leave loaded == NO, if it ever starts existing, we'll handle it
                }

            }];
            [weakSelf.sparks addObject:outerSpark];
        }
    }];

    WilddogHandle childRemovedHandle = [query observeEventType:WEventTypeChildRemoved withBlock:^(WDataSnapshot *snapshot) {
        // TODO: handle overflowing a spark out of the feed. In this app, we keep them in the table so that they are still visible
    }];

    // Since value events fire after child events, this observer lets us know when we've gotten a good initial snapshot of the data
    [query observeSingleEventOfType:WEventTypeValue withBlock:^(WDataSnapshot *snapshot) {
        [weakSelf.delegate timelineDidLoad:feedId];
    }];

    FeedHandlers* handlers = [[FeedHandlers alloc] init];
    handlers.ref = ref;
    handlers.childAddedHandle = childAddedHandle;
    handlers.childRemovedHandle = childRemovedHandle;
    [self.feeds setObject:handlers forKey:feedId];
    return feedId;
    
}


- (void) stopObservingTimeline:(NSString *)timeline {
    // Part of cleanup, remove observers so we don't leak memory
    FeedHandlers* handlers = [self.feeds objectForKey:timeline];
    if (handlers) {
        [self stopObservingFeed:handlers];
        [self.feeds removeObjectForKey:timeline];
    }
}

- (NSString *) observeSparksForUser:(NSString *)userId {
    // Used when looking at a profile, show 50 most recent sparks
    Wilddog* ref = [[[self.root childByAppendingPath:@"users"] childByAppendingPath:userId] childByAppendingPath:@"sparks"];
    return [self observeFeed:ref withCount:50];
    
}

- (NSString *) observeLoggedInUserTimeline {
    // Show the home feed for the logged in user
    if (!self.loggedInUser) {
        return nil;
    } else {
        Wilddog* ref = [[[self.root childByAppendingPath:@"users"] childByAppendingPath:self.loggedInUser.userId] childByAppendingPath:@"feed"];
        return [self observeFeed:ref withCount:100];
    }
}

- (NSString *) observeLatestSparks {
    // Grab the latest from the global firehose of latest sparks
    Wilddog* ref = [self.root childByAppendingPath:@"recent-sparks"];
    return [self observeFeed:ref withCount:100];
}


- (double) currentTimestamp {
    // Incorporate the timestamp from wilddog to get a good estimate of the time
    return ([[NSDate date] timeIntervalSince1970] * 1000.0) + self.serverTimeOffset;
}

- (void) postSpark:(NSString *)text completionBlock:(ffbt_void_nserror)block {
    // Post a spark and fan it out to the relevant locations

    Wilddog* sparkRef = [[self.root childByAppendingPath:@"sparks"] childByAutoId];
    NSString* sparkRefId = sparkRef.key;

    NSNumber* ts = [NSNumber numberWithDouble:[self currentTimestamp]];
    NSDictionary* spark = @{@"author": self.loggedInUser.userId, @"by": self.loggedInUser.fullName, @"content": text, @"timestamp": ts};

    ffbt_void_nserror userBlock = [block copy];
    __weak Firefeed* weakSelf = self;
    [sparkRef setValue:spark withCompletionBlock:^(NSError *error, Wilddog* ref) {
        if (error) {
            userBlock(error);
        } else if (weakSelf) {
            // Do fanout
            // Add spark to list of sparks sent by this user
            [[[weakSelf.userRef childByAppendingPath:@"sparks"] childByAppendingPath:sparkRefId] setValue:@YES];

            // Add spark to the user's own feed
            [[[weakSelf.userRef childByAppendingPath:@"feed"] childByAppendingPath:sparkRefId] setValue:@YES];

            // Mark the user as having recently sparked.
            Wilddog* recentUsersRef = [weakSelf.root childByAppendingPath:@"recent-users"];
            [[recentUsersRef childByAppendingPath:weakSelf.loggedInUser.userId] setValue:@YES andPriority:ts];

            Wilddog* recentSparksRef = [weakSelf.root childByAppendingPath:@"recent-sparks"];
            [[recentSparksRef childByAppendingPath:sparkRefId] setValue:@YES andPriority:ts];

            // fanout to followers
            [[weakSelf.userRef childByAppendingPath:@"followers"] observeSingleEventOfType:WEventTypeValue withBlock:^(WDataSnapshot *snapshot) {
                for (WDataSnapshot* childSnap in snapshot.children) {
                    NSString* followerId = childSnap.key;
                    [[[[[weakSelf.root childByAppendingPath:@"users"] childByAppendingPath:followerId] childByAppendingPath:@"feed"] childByAppendingPath:sparkRefId] setValue:@YES];
                }
            }];
            userBlock(nil);
        }
    }];
}

- (void) observeUserInfo:(NSString *)userId {
    // Observe the profile data of a single user
    __weak Firefeed* weakSelf = self;
    FirefeedUser* user = [FirefeedUser loadFromRoot:weakSelf.root withUserId:userId completionBlock:^(FirefeedUser *user) {
        [weakSelf.delegate userDidUpdate:user];
    }];
    [self.users addObject:user];
}

- (void) startFollowingUser:(NSString *)userId {
    // Performs the necessary operations to follow a user:
    // 1. Set the followee into the followers list of following
    // 2. Set the follower into the followee's list of followers
    // 3. Copy in some recent sparks to fill up the follower's feed
    Wilddog* userRef = [[self.root childByAppendingPath:@"users"] childByAppendingPath:self.loggedInUser.userId];

    Wilddog* followingRef = [[userRef childByAppendingPath:@"following"] childByAppendingPath:userId];
    [followingRef setValue:@YES withCompletionBlock:^(NSError *error, Wilddog* ref) {
        Wilddog* followerRef = [[self.root childByAppendingPath:@"users"] childByAppendingPath:userId];

        [[[followerRef childByAppendingPath:@"followers"] childByAppendingPath:self.loggedInUser.userId] setValue:@YES];

        // Now, copy some sparks into our feed
        Wilddog* feedRef = [userRef childByAppendingPath:@"feed"];
        
        //改动—01
        [[followerRef childByAppendingPath:@"sparks"] observeEventType:WEventTypeValue withBlock:^(WDataSnapshot *snapshot) {

            for (WDataSnapshot* childSnap in snapshot.children) {
                [[feedRef childByAppendingPath:childSnap.key] setValue:@YES];
            }
        }];
    }];
}

- (void) stopFollowingUser:(NSString *)userId {
    // We leave the sparks from the followee, but remove the follower from the followee's list of followers
    // Also, remove the followee from the follower's list of following
    Wilddog* userRef = [[self.root childByAppendingPath:@"users"] childByAppendingPath:self.loggedInUser.userId];

    Wilddog* followingRef = [[userRef childByAppendingPath:@"following"] childByAppendingPath:userId];
    [followingRef removeValueWithCompletionBlock:^(NSError *error, Wilddog* ref) {
        Wilddog* followerRef = [[self.root childByAppendingPath:@"users"] childByAppendingPath:userId];

        [[[followerRef childByAppendingPath:@"followers"] childByAppendingPath:self.loggedInUser.userId] removeValue];
    }];
}

- (void) saveUser:(FirefeedUser *)user {
    // Pass through to the user object to update itself
    [user updateFromRoot:self.root];
}

- (void) userDidUpdate:(FirefeedUser *)user {
    // Pass through to our delegate that a user was updated
    [self.delegate userDidUpdate:user];
}

@end
