//
//  ComposeViewController.m
//  iFirefeed
//
// Forked from https://github.com/romaonthego/REComposeViewController
//

#import <QuartzCore/QuartzCore.h>
#import "ComposeViewController.h"
#import "ComposeSheetView.h"
#import "ComposeBackgroundView.h"

@interface ComposeViewController () <ComposeSheetViewDelegate>

@property (strong, nonatomic) ComposeSheetView* sheetView;
@property (strong, nonatomic) ComposeBackgroundView* backgroundView;
@property (strong, nonatomic) UIView* containerView;
@property (strong, nonatomic) UIView* backView;

@end

@implementation ComposeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sheetView = [[ComposeSheetView alloc] initWithFrame:CGRectMake(0, 0, self.currentWidth - 8, 202)];
    }
    return self;
}

- (int)currentWidth
{
    UIScreen *screen = [UIScreen mainScreen];
    return (!UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) ? screen.bounds.size.width : screen.bounds.size .height;
}

- (void) presentFromRootViewControllerWithText:(NSString *)text submitButtonTitle:(NSString *)title headerTitle:(NSString *)headerTitle characterLimit:(NSInteger)charLimit {
    [self.sheetView setSubmitTitle:title];
    [self.sheetView setInitialText:text];
    [self.sheetView setHeaderTitle:headerTitle];
    [self.sheetView setCharLimit:charLimit];
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [self presentFromViewController:rootViewController];
}

- (void) presentFromViewController:(UIViewController *)controller {
    [controller addChildViewController:self];
    [controller.view addSubview:self.view];
    [self didMoveToParentViewController:controller];
}

- (void) loadView {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    self.view = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    __typeof(&*self) __weak weakSelf = self;

    [UIView animateWithDuration:0.4 animations:^{
        [weakSelf.sheetView.textView becomeFirstResponder];
        [weakSelf layoutWithOrientation:weakSelf.interfaceOrientation width:weakSelf.view.frame.size.width height:weakSelf.view.frame.size.height];
    }];

    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         weakSelf.backgroundView.alpha = 0.8;
                     } completion:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewOrientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _backgroundView = [[ComposeBackgroundView alloc] initWithFrame:self.view.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.centerOffset = CGSizeMake(0, - self.view.frame.size.height / 2);
    _backgroundView.alpha = 0;
    [self.view addSubview:_backgroundView];


    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 202)];
    _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _backView = [[UIView alloc] initWithFrame:CGRectMake(4, 0, self.currentWidth - 8, 202)];
    _backView.layer.cornerRadius = 10;
    _backView.layer.shadowOpacity = 0.7;
    _backView.layer.shadowColor = [UIColor blackColor].CGColor;
    _backView.layer.shadowOffset = CGSizeMake(3, 5);
    _backView.layer.shouldRasterize = YES;
    _backView.layer.rasterizationScale = [UIScreen mainScreen].scale;

    _sheetView.frame = _backView.bounds;
    _sheetView.layer.cornerRadius = 10;
    _sheetView.clipsToBounds = YES;
    _sheetView.delegate = self;

    [_containerView addSubview:_backView];
    [self.view addSubview:_containerView];
    [_backView addSubview:_sheetView];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutWithOrientation:(UIInterfaceOrientation)interfaceOrientation width:(NSInteger)width height:(NSInteger)height {
    NSInteger offset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60 : 4;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        CGRect frame = _containerView.frame;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            offset *= 2;
        }

        NSInteger verticalOffset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 316 : 216;

        NSInteger containerHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? _containerView.frame.size.height : _containerView.frame.size.height;
        frame.origin.y = (height - verticalOffset - containerHeight) / 2;
        if (frame.origin.y < 20) frame.origin.y = 20;
        _containerView.frame = frame;

        _containerView.clipsToBounds = YES;
        _backView.frame = CGRectMake(offset, 0, width - offset*2, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 202 : 140);
        _sheetView.frame = _backView.bounds;

    } else {
        CGRect frame = _containerView.frame;
        frame.origin.y = (height - 216 - _containerView.frame.size.height) / 2;
        if (frame.origin.y < 20) frame.origin.y = 20;
        _containerView.frame = frame;
        _backView.frame = CGRectMake(offset, 0, width - offset*2, 202);
        _sheetView.frame = _backView.bounds;

    }

    [_sheetView.navigationBar sizeToFit];

    CGRect textViewFrame = _sheetView.textView.frame;
    textViewFrame.size.width = _sheetView.frame.size.width;
    _sheetView.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0);
    textViewFrame.size.height = _sheetView.frame.size.height - _sheetView.navigationBar.frame.size.height - 3;
    _sheetView.textView.frame = textViewFrame;

    CGRect textViewContainerFrame = _sheetView.textViewContainer.frame;
    textViewContainerFrame.origin.y = _sheetView.navigationBar.frame.size.height;
    textViewContainerFrame.size.height = _sheetView.frame.size.height - _sheetView.navigationBar.frame.size.height;
    _sheetView.textViewContainer.frame = textViewContainerFrame;
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [_sheetView.textView resignFirstResponder];
    __typeof(&*self) __weak weakSelf = self;

    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = _containerView.frame;
        frame.origin.y = self.view.frame.size.height;
        weakSelf.containerView.frame = frame;
    }];

    [UIView animateWithDuration:0.4
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         weakSelf.backgroundView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [weakSelf.view removeFromSuperview];
                         [weakSelf removeFromParentViewController];
                     }];
}

- (void)cancelButtonPressed {
    [_delegate composeViewController:self didFinishWithText:nil];
}

- (void)postButtonPressed {
    NSString* text = _sheetView.textView.text;
    [_delegate composeViewController:self didFinishWithText:text];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

- (void)viewOrientationDidChanged:(NSNotification *)notification {
    [self layoutWithOrientation:self.interfaceOrientation width:self.view.frame.size.width height:self.view.frame.size.height];
}

@end
