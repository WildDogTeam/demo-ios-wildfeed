//
//  FirefeedSpark.m
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "FirefeedSpark.h"

@interface FirefeedSpark ()

@property (nonatomic) WilddogHandle valueHandle;
@property (nonatomic) BOOL loaded;
@property (strong, nonatomic) Wilddog* ref;

@end

typedef void (^ffbt_void_ffspark)(FirefeedSpark* spark);

@implementation FirefeedSpark

+ (FirefeedSpark *) loadFromRoot:(Wilddog *)root withSparkId:(NSString *)sparkId block:(ffbt_void_ffspark)block {

    ffbt_void_ffspark userBlock = [block copy];
    Wilddog* sparkRef = [[root childByAppendingPath:@"sparks"] childByAppendingPath:sparkId];
    return [[FirefeedSpark alloc] initWithRef:sparkRef andBlock:userBlock];
    
    
}


- (id) initWithRef:(Wilddog *)ref andBlock:(ffbt_void_ffspark)block {
    self = [super init];
    
    if (self) {
        self.ref = ref;
        // Load the data for this spark from wilddog
        self.valueHandle = [ref observeEventType:WEventTypeValue withBlock:^(WDataSnapshot *snapshot) {
            id rawVal = snapshot.value;
            if (rawVal == [NSNull null]) {
                block(nil);
            } else {
                NSDictionary* val = rawVal;
                self.authorId = [val objectForKey:@"author"];
                self.authorName = [val objectForKey:@"by"];
                self.content = [val objectForKey:@"content"];
                self.timestamp = [(NSNumber *)[val objectForKey:@"timestamp"] doubleValue];
                block(self);
            }
        }];
    }
    return self;
}

- (NSComparisonResult) compare:(FirefeedSpark *)other {
    // If two sparks have the same id, consider them equivalent
    return [self.ref.key compare:other.ref.key];
}

- (void) stopObserving {
    [self.ref removeObserverWithHandle:self.valueHandle];
}

- (NSURL *) authorPicURL {
    NSString *author;
    // Check for uid vs id, so we can know how to query the qq API for the profile picture
    if ([self.authorId containsString:@"qq:"]) {
        NSArray *stringPieces = [self.authorId componentsSeparatedByString:@":"];
        author = stringPieces[1];
    } else {
        author = self.authorId;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://qzapp.qlogo.cn/qzapp/1104855396/%@/30", author]];
}

@end






















