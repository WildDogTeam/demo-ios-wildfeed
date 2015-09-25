//
//  ProfileEditController.h
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOGlassButton.h"

@interface ProfileEditController : UIViewController

@property (weak, nonatomic) IBOutlet MOGlassButton *bioEdit;
@property (weak, nonatomic) IBOutlet MOGlassButton *locationEdit;

@property (weak, nonatomic) IBOutlet UITextView *bioText;
@property (weak, nonatomic) IBOutlet UITextView *locationText;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UITextView *aboutText;
@end
