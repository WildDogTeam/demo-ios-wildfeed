//
//  FirefeedAuth.h
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Wilddog/Wilddog.h>

//#define _FB_DEBUG

#ifdef _FB_DEBUG
// debug
#define kQQAppId @"321090668014055"
#define kwilddogRoot @"https://feed.fblocal.com:9000"

#else

// Public
#define kQQAppId @"1104855396"
#define kWilddogRoot @"https://feed.wilddogio.com"

#endif

@interface FirefeedAuth : NSObject

+ (long) watchAuthForRef:(Wilddog *)ref withBlock:(void (^)(NSError* error, WAuthData *user))block;
+ (void) stopWatchingAuthForRef:(Wilddog *)ref withHandle:(long)handle;
+ (void) loginRef:(Wilddog *)ref toQQAppWithId:(NSString *)appId;
+ (void) logoutRef:(Wilddog *)ref;

@end
