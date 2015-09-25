//
//  UserSearchViewController.m
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "UserSearchViewController.h"
#import "ProfileViewController.h"


@interface UserSearchViewController () <UISearchBarDelegate, UISearchDisplayDelegate, FirefeedSearchDelegate>

@property (strong, nonatomic) UISearchDisplayController* searchController;
@property (strong, nonatomic) UISearchBar* searchBar;

@end

@implementation UserSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size {
    //Create a context of the appropriate size
    UIGraphicsBeginImageContext(size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();

    //Build a rect of appropriate size at origin 0,0
    CGRect fillRect = CGRectMake(0,0,size.width,size.height);

    //Set the fill color
    CGContextSetFillColorWithColor(currentContext, color.CGColor);

    //Fill the color
    CGContextFillRect(currentContext, fillRect);

    //Snap the picture and close the context
    UIImage *retval = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retval;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:255.0f / 255.0f green:252.0f / 255.0f blue:244.0f / 255.0f alpha:1.0f]];
    UIColor* background = [UIColor colorWithRed:255.0f / 255.0f green:252.0f / 255.0f blue:244.0f / 255.0f alpha:1.0f];
    self.firefeedSearch.delegate = self;
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    self.searchBar.tintColor = [UIColor colorWithRed:0xff / 255.0f green:0xea / 255.0f blue:0xb3 / 255.0f alpha:1.0];
    self.searchBar.delegate = self;
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.firefeedSearch.resultsTable = self.searchController.searchResultsTableView;
    self.searchController.delegate = self;
    self.searchController.searchResultsTableView.backgroundColor = background;
    self.searchController.searchResultsTableView.separatorColor = [UIColor colorWithRed:0x7b / 255.0f green:0x5f / 255.0f blue:0x11 / 255.0f alpha:1.0f];
    [self.view addSubview:self.searchBar];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    // Done searching, no user was selected
    [self.delegate searchWasCancelled];
}


- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Pass through to the search handler
    return [self.firefeedSearch searchTextDidUpdate:searchString];
}

- (void) userIdWasSelected:(NSString *)userId {
    // Done searching, a user was selected
    [self.delegate userWasSelected:userId];
}

@end
