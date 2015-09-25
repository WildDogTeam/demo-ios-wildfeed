//
//  FirefeedSpark.h
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Wilddog/Wilddog.h>

@interface FirefeedSpark : NSObject

+ (FirefeedSpark *) loadFromRoot:(Wilddog *)root withSparkId:(NSString *)sparkId block:(void (^)(FirefeedSpark* spark))block;

- (void) stopObserving;

@property (strong, nonatomic) NSString* authorId;
@property (strong, nonatomic) NSString* authorName;
@property (strong, nonatomic) NSString* content;
@property (nonatomic) double timestamp;
@property (readonly) NSURL* authorPicURL;

@end
