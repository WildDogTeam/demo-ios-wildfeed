//
//  FirefeedUser.h
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Wilddog/Wilddog.h>

@protocol FirefeedUserDelegate;

@interface FirefeedUser : NSObject

+ (FirefeedUser *) loadFromRoot:(Wilddog *)root withUserId:(NSString *)userId completionBlock:(void (^)(FirefeedUser* user))block;
+ (FirefeedUser *) loadFromRoot:(Wilddog *)root withUserData:(NSDictionary *)userData completionBlock:(void (^)(FirefeedUser* user))block;

- (void) updateFromRoot:(Wilddog *)root;
- (void) stopObserving;

@property (strong, nonatomic) NSString* userId;
@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* fullName;
@property (strong, nonatomic) NSString* location;
@property (strong, nonatomic) NSString* bio;
@property (readonly) NSURL* picUrl;
@property (readonly) NSURL* picURLSmall;
@property (weak, nonatomic) id<FirefeedUserDelegate> delegate;

@end

@protocol FirefeedUserDelegate

- (void) userDidUpdate:(FirefeedUser *)user;

@end
