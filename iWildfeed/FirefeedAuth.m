//
//  FirefeedAuth.m
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "FirefeedAuth.h"

#import <TencentOpenAPI/TencentOAuth.h>


typedef void (^ffbt_void_nserror_user)(NSError* error, WAuthData* user);
typedef void (^ffbt_void_void)(void);

// This class manages multiple concurrent auth requests (login, logout, status) against the same wilddog
@interface FirefeedAuthData : NSObject<TencentSessionDelegate>
{
    NSMutableDictionary* _blocks;
    Wilddog* _ref;
    long _luid;
    WAuthData* _user;
    WilddogHandle _authHandle;
    
    TencentOAuth *_tencentOAuth;
    NSArray *_permissions;
}

- (id) initWithRef:(Wilddog *)ref;
- (long) checkAuthStatus:(ffbt_void_nserror_user)block;
- (void) loginToAppWithId:(NSString *)appId;
- (void) logout;

@end

@implementation FirefeedAuthData

- (id) initWithRef:(Wilddog *)ref {
    self = [super init];
    if (self) {
        // Start at 1 so it works with if (luid) {...}
        _luid = 1;
        _ref = ref;
        _user = nil;
        // Keep an eye on what wilddog says our authentication status is
        
        _authHandle = [_ref observeAuthEventWithBlock:^(WAuthData *user) {
            // This is the new style, but there doesn't appear to be any way to tell which way the user is going, online or offline?
            if ((user == nil) && (_user != nil)) {
                //[self onAuthStatusError:nil user:nil];
            }
        }];
        
        
        
        _blocks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) dealloc {
    if (_authHandle != NSNotFound) {
        [_ref removeAuthEventObserverWithHandle:_authHandle];
    }
}

- (void) loginToAppWithId:(NSString *)appId {
    
    _tencentOAuth = [[TencentOAuth alloc]initWithAppId:@"1104855396" andDelegate:self];
    
    _permissions = [NSArray arrayWithObjects:@"get_user_info", @"get_simple_userinfo", @"add_t", nil];
    
    [_tencentOAuth authorize:_permissions inSafari:NO];

    
}

//登录成功：
- (void)tencentDidLogin
{
    
    Wilddog *dog = [[Wilddog alloc] initWithUrl:@"https://feed.wilddogio.com"];
    [dog authWithOAuthProvider:@"qq" parameters:@{@"access_token":_tencentOAuth.accessToken,@"openId":_tencentOAuth.openId} withCompletionBlock:^(NSError *error, WAuthData *authData) {
        
        
        NSLog(@"qq登录成功");
        
        
       }];
    
    
}

//非网络错误导致登录失败：
-(void)tencentDidNotLogin:(BOOL)cancelled
{
    //[Utils hidenProgressHUdshowInView:self.view];
}
//网络错误导致登录失败：
-(void)tencentDidNotNetWork
{
    //[Utils hidenProgressHUdshowInView:self.view];
}



- (void) populateSearchIndicesForUser:(WAuthData *)user {
    // For each user, we list them in the search index twice. Once by first name and once by last name. We include the id at the end to guarantee uniqueness
    Wilddog* firstNameRef = [_ref.root childByAppendingPath:@"search/firstName"];
    Wilddog* lastNameRef = [_ref.root childByAppendingPath:@"search/lastName"];

    NSString* firstName = [user.providerData objectForKey:@"first_name"];
    NSString* lastName = [user.providerData objectForKey:@"last_name"];
    NSString* firstNameKey = [[NSString stringWithFormat:@"%@_%@_%@", firstName, lastName, user.uid] lowercaseString];
    NSString* lastNameKey = [[NSString stringWithFormat:@"%@_%@_%@", lastName, firstName, user.uid] lowercaseString];

    [[firstNameRef childByAppendingPath:firstNameKey] setValue:user.uid];
    [[lastNameRef childByAppendingPath:lastNameKey] setValue:user.uid];
}

- (void) logout {
    // Pass through to wilddog to unauth
    [_ref unauth];
}

// Assumes block is already on the heap
- (long) checkAuthStatus:(ffbt_void_nserror_user)block {
    long handle = _luid++;
    NSNumber* luid = [NSNumber numberWithLong:handle];

    [_blocks setObject:block forKey:luid];
    if (_user) {
        // we already have a user logged in
        // force async to be consistent
        ffbt_void_void cb = ^{
            block(nil, _user);
        };
        [self performSelector:@selector(executeCallback:) withObject:[cb copy] afterDelay:0];
    } else if (_blocks.count == 1) {
        // This is the first block for this wilddog, kick off the login process
        [_ref observeAuthEventWithBlock:^(WAuthData *user) {
            if (user) {
                [self onAuthStatusError:nil user:user];
            } else {
                [self onAuthStatusError:nil user:nil];
            }
        }];
    }
    return handle;
}

- (void) stopWatchingAuthStatus:(long)handle {
    NSNumber* luid = [NSNumber numberWithLong:handle];

    [_blocks removeObjectForKey:luid];
}

- (void) onAuthStatusError:(NSError *)error user:(WAuthData *)user {
    if (user) {
        _user = user;
    } else {
        _user = nil;
    }
    
    for (NSNumber* handle in _blocks) {
        // tell everyone who's listening
        ffbt_void_nserror_user block = [_blocks objectForKey:handle];
        block(error, user);
    }
}

// Used w/ performSelector. Basically a hack to execute a block asynchronously
- (void) executeCallback:(ffbt_void_void)callback {
    callback();
}

@end

@interface FirefeedAuth ()

@property (strong, nonatomic) NSMutableDictionary* wilddogs;

@end

@implementation FirefeedAuth

+ (FirefeedAuth *) singleton {
    // We use a singleton here
    static dispatch_once_t pred;
    static FirefeedAuth* theSingleton;
    dispatch_once(&pred, ^{
        theSingleton = [[FirefeedAuth alloc] init];
    });
    return theSingleton;
}

// Pass-through methods to the singleton
+ (long) watchAuthForRef:(Wilddog *)ref withBlock:(void (^)(NSError *, WAuthData *))block {
    
    return [[self singleton] checkAuthForRef:ref withBlock:block];
    
}

+ (void) stopWatchingAuthForRef:(Wilddog *)ref withHandle:(long)handle {
    [[self singleton] stopWatchingAuthForRef:ref withHandle:handle];
}

+ (void) loginRef:(Wilddog *)ref toQQAppWithId:(NSString *)appId {
    [[self singleton] loginRef:ref toQQAppWithId:appId];
}

+ (void) logoutRef:(Wilddog *)ref {
    [[self singleton] logoutRef:ref];
}

- (id) init {
    self = [super init];
    if (self) {
        self.wilddogs = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) loginRef:(Wilddog *)ref toQQAppWithId:(NSString *)appId {

    NSString* wilddogId = ref.root.description;

    // Pass to the FirefeedAuthData object, which manages multiple auth requests against the same wilddog
    FirefeedAuthData* authData = [self.wilddogs objectForKey:wilddogId];
    if (!authData) {
        authData = [[FirefeedAuthData alloc] initWithRef:ref.root];
        [self.wilddogs setObject:authData forKey:wilddogId];
    }
    [authData loginToAppWithId:appId];
}

- (void) logoutRef:(Wilddog *)ref {
    NSString* wilddogId = ref.root.description;

    // Pass to the FirefeedAuthData object, which manages multiple auth requests against the same wilddog
    FirefeedAuthData* authData = [self.wilddogs objectForKey:wilddogId];
    if (!authData) {
        authData = [[FirefeedAuthData alloc] initWithRef:ref.root];
        [self.wilddogs setObject:authData forKey:wilddogId];
    }

    [authData logout];
}


- (void) stopWatchingAuthForRef:(Wilddog *)ref withHandle:(long)handle {
    NSString* wilddogId = ref.root.description;

    // Pass to the FirefeedAuthData object, which manages multiple auth requests against the same wilddog
    FirefeedAuthData* authData = [self.wilddogs objectForKey:wilddogId];
    if (authData) {
        [authData stopWatchingAuthStatus:handle];
    }
}

- (long) checkAuthForRef:(Wilddog *)ref withBlock:(ffbt_void_nserror_user)block {
    ffbt_void_nserror_user userBlock = [block copy];
    NSString* wilddogId = ref.root.description;

    // Pass to the FirefeedAuthData object, which manages multiple auth requests against the same wilddog
    FirefeedAuthData* authData = [self.wilddogs objectForKey:wilddogId];
   
    if (!authData) {
        
        
        authData = [[FirefeedAuthData alloc] initWithRef:ref.root];
        [self.wilddogs setObject:authData forKey:wilddogId];
        
        
    }

    return [authData checkAuthStatus:userBlock];
}

@end














