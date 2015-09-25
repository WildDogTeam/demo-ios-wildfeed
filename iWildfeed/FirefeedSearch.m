//
//  FirefeedSearch.m
//  iFirefeed
//
//  Created by IMacLi on 4/23/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "FirefeedSearch.h"
#import "UIImageView+WebCache.h"

#define CHAR_THRESHOLD 3
#define IS_VALID_CHAR(c) (c != '.' && c != '#' && c != '$' && c != '/' && c != '[' && c != ']')

@interface TupleRefHandle : NSObject

@property (strong, nonatomic) WQuery* ref;
@property (nonatomic) WilddogHandle handle;

@end

@implementation TupleRefHandle

@end

// Small extensions to NSString for some ease-of-use in searching
@interface NSString (FirefeedSearch)

- (NSString *) nextLowerCaseKey;
- (BOOL) isValidKey;

@end

@implementation NSString (FirefeedSearch)

- (NSString *) nextLowerCaseKey {
    unichar c = [self characterAtIndex:self.length - 1];

    if (c == USHRT_MAX) {
        // Seems unlikely, but we should handle it
        return nil;
    } else {
        do {
            c++;
        } while (!IS_VALID_CHAR(c));

        return [NSString stringWithFormat:@"%@%c", [self substringToIndex:self.length - 1], c];
    }
}

- (BOOL) isValidKey {
    for (int i = 0; i < self.length; ++i) {
        if (!IS_VALID_CHAR([self characterAtIndex:i])) {
            return NO;
        }
    }
    return YES;
}

@end

// Encapsulate a search result
@interface SearchResult : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* userId;
@property (readonly, nonatomic) NSString* displayName;

@end

@implementation SearchResult

- (NSString *) displayName {
    return [[self.name stringByReplacingOccurrencesOfString:@"_" withString:@" "] capitalizedString];
}

- (NSURL *) picURLSmall {
    NSString *author;
    // Check for uid vs id, so we can know how to query the QQ API for the profile picture
    if ([self.userId containsString:@"qq:"]) {
        NSArray *stringPieces = [self.userId componentsSeparatedByString:@":"];
        author = stringPieces[1];
    } else {
        author = self.userId;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://qzapp.qlogo.cn/qzapp/1104855396/%@/30", self.userId]];
}
@end

@protocol NameSearchDelegate;

@interface NameSearch : NSObject {
    NSString* _term;
    Wilddog* _root;
    NSMutableArray* _handles;
    NSMutableArray* _firstNameResults;
    NSMutableArray* _lastNameResults;
    NSArray* _stems;
}

- (id) initWithRef:(Wilddog *)ref andStem:(NSString *)stem;

- (BOOL) containsTerm:(NSString *)term;
- (BOOL) updateTerm:(NSString *)term;

@property (weak, nonatomic) id<NameSearchDelegate> delegate;

@end

@protocol NameSearchDelegate <NSObject>

- (void) resultsDidChange:(NSArray *)results;

@end

@implementation NameSearch

// Set up a new search with a given term
- (id) initWithRef:(Wilddog *)ref andStem:(NSString *)stem {
    self = [super init];
    if (self) {
        _term = stem;
        _root = ref;
        _firstNameResults = [[NSMutableArray alloc] init];
        _lastNameResults = [[NSMutableArray alloc] init];
        _handles = [[NSMutableArray alloc] init];
        _stems = [self generateStems:stem];
        [self startSearch];
    }
    return self;
}

// Given the term that was used to create the search, create the various permutations that we want to query over
// We do this so we can allow spaces in first and last names without automatically assuming that a space delimits the two

- (NSArray *) generateStems:(NSString *)stem {
    stem = [[stem substringToIndex:CHAR_THRESHOLD] lowercaseString];
    NSMutableArray* stems = [[NSMutableArray alloc] init];
    [stems addObject:stem];
    // For each character, if it's a space, add a permutation that includes the delimiter instead of the space
    for (int i = 0; i < CHAR_THRESHOLD; ++i) {
        unichar c = [stem characterAtIndex:i];
        if (c == ' ') {
            // Add a search for the pipe character
            NSString* prefix = c > 0 ? [stem substringToIndex:i] : @"";
            NSString* postfix = c < stem.length - 1 ? [stem substringFromIndex:i + 1] : @"";
            NSString* pipeStem = [NSString stringWithFormat:@"%@%c%@", prefix, '|', postfix];
            [stems addObject:pipeStem];
        }
    }
    return stems;
}

- (void) dealloc {
    for (TupleRefHandle* tuple in _handles) {
        [tuple.ref removeObserverWithHandle:tuple.handle];
    }
}

// For a given stem, create a window between the stem and the next valid key of the same length, alphabetically.
// Return anything inbetween as a first name search result
// Then, do it a second time for last name search
- (void) startSearchForStem:(NSString *)stem {
    __weak NameSearch* weakSelf = self;
    NSString* endKey = [stem nextLowerCaseKey];
    WQuery* firstNameQuery = [[_root childByAppendingPath:@"search/firstName"] queryStartingAtValue:nil childKey:stem];
    WQuery* lastNameQuery = [[_root childByAppendingPath:@"search/lastName"] queryStartingAtValue:nil childKey:stem];
    if (endKey) {
        firstNameQuery = [firstNameQuery queryEndingAtValue:nil childKey:endKey];
        lastNameQuery = [lastNameQuery queryEndingAtValue:nil childKey:endKey];
    }
    WilddogHandle handle = [firstNameQuery observeEventType:WEventTypeChildAdded withBlock:^(WDataSnapshot *snapshot) {
        [weakSelf newFirstNameResult:snapshot];
    }];
    TupleRefHandle* tuple = [[TupleRefHandle alloc] init];
    tuple.ref = firstNameQuery;
    tuple.handle = handle;
    [_handles addObject:tuple];

    handle = [lastNameQuery observeEventType:WEventTypeChildAdded withBlock:^(WDataSnapshot *snapshot) {
       
          [weakSelf newLastNameResult:snapshot];
        
    }];
    
    
    
    
    tuple = [[TupleRefHandle alloc] init];
    tuple.ref = lastNameQuery;
    //tuple.handle = handle;
    [_handles addObject:tuple];
}

- (void) startSearch {
    for (NSString* stem in _stems) {
        [self startSearchForStem:stem];
    }
}

// The next two methods do some matching clientside to see if this result matches what the user has typed.
// Since we don't update our search criteria when the user types more characters, we have to potenitially filter out some results clientside
- (void) newFirstNameResult:(WDataSnapshot *)snapshot {
    SearchResult* result = [[SearchResult alloc] init];
    result.userId = snapshot.value;
    NSArray* segments = [[snapshot.key stringByReplacingOccurrencesOfString:@"," withString:@"."] componentsSeparatedByString:@"|"];
    result.name = [NSString stringWithFormat:@"%@ %@", [segments objectAtIndex:0], [segments objectAtIndex:1]];
    [_firstNameResults addObject:result];
    if ([result.name hasPrefix:_term]) {
        [self raiseFilteredResults];
    }
}

- (void) newLastNameResult:(WDataSnapshot *)snapshot {
    SearchResult* result = [[SearchResult alloc] init];
    result.userId = snapshot.value;    
    NSArray* segments = [[snapshot.key stringByReplacingOccurrencesOfString:@"," withString:@"."] componentsSeparatedByString:@"|"];
    result.name = [NSString stringWithFormat:@"%@, %@", [segments objectAtIndex:0], [segments objectAtIndex:1]];
    [_lastNameResults addObject:result];
    if ([result.name hasPrefix:_term]) {
        [self raiseFilteredResults];
    }
}

// Go through all of our search results and determine which ones match the current term that the user has typed in the search box
// Send these to the delegate
- (void) raiseFilteredResults {
    NSMutableArray* results = [[NSMutableArray alloc] init];
    for (SearchResult* result in _firstNameResults) {
        if ([result.name hasPrefix:_term]) {
            [results addObject:result];
        }
    }
    for (SearchResult* result in _lastNameResults) {
        if ([result.name hasPrefix:_term]) {
            [results addObject:result];
        }
    }
    [self.delegate resultsDidChange:results];
}

// Check if the given term matches one of our stems
- (BOOL) containsTerm:(NSString *)term {
    if (term.length < CHAR_THRESHOLD) {
        return NO;
    } else {
        for (NSString* stem in _stems) {
            if ([term hasPrefix:stem]) {
                return YES;
            }
        }
        return NO;
    }
}

// Update the term to match against and re-filter all of our results
- (BOOL) updateTerm:(NSString *)term {
    _term = term;
    [self raiseFilteredResults];
    return NO;
}

@end

@interface FirefeedSearch () <NameSearchDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Wilddog* root;
@property (strong, nonatomic) NSString* searchBase;
@property (strong, nonatomic) NSString* searchTerm;
@property (strong, nonatomic) NameSearch* currentSearch;
@property (strong, nonatomic) NSArray* currentResults;


@end

@implementation FirefeedSearch

- (id) initWithRef:(Wilddog *)ref {
    self = [super init];
    if (self) {
        self.root = ref;
        self.searchTerm = @"";
        self.searchBase = nil;
        self.currentResults = @[];
    }
    return self;
}

- (void) setResultsTable:(UITableView *)resultsTable {
    _resultsTable = resultsTable;
    _resultsTable.delegate = self;
    _resultsTable.dataSource = self;
}

- (void) resultsDidChange:(NSArray *)results {
    self.currentResults = results;
    [self.resultsTable reloadData];
}

- (void) startSearch:(NSString *)text {
    if (text.length >= CHAR_THRESHOLD) {
        self.currentSearch = [[NameSearch alloc] initWithRef:_root andStem:text];
        self.currentSearch.delegate = self;
    }
}

- (void) stopSearch {
    self.currentSearch = nil;
    [self resultsDidChange:@[]];
}

// Check basic validity of the search term, and pass it to the search object
- (BOOL) searchTextDidUpdate:(NSString *)text {
    NSString* term = [text lowercaseString];
    if (![term isValidKey]) {
        [self stopSearch];
        return YES;
    } else if (self.currentSearch) {
        // We have a term
        if ([self.currentSearch containsTerm:term]) {
            return [self.currentSearch updateTerm:term];
        } else {
            [self stopSearch];
            return YES;
        }
    } else {
        // No current term. Save this one if it's longer than 3 chars
        [self startSearch:term];
        return NO;
    }
}

// The next few methods deal with managing the table of results
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentResults.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"SearchResult";

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    SearchResult* result = [self.currentResults objectAtIndex:indexPath.row];
    cell.textLabel.text = result.displayName;
    [cell.imageView sd_setImageWithURL:result.picURLSmall placeholderImage:[UIImage imageNamed:@"placekitten.png"]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResult* result = [self.currentResults objectAtIndex:indexPath.row];
    [self.delegate userIdWasSelected:result.userId];
}

@end
