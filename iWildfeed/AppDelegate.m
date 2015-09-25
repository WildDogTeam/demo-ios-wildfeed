//
//  AppDelegate.m
//  iFirefeed
//
//  Created by IMacLi on 4/2/13.
//  Copyright (c) 2013 wilddog. All rights reserved.
//

#import "AppDelegate.h"

#import <TencentOpenAPI/TencentOAuth.h>

#import "HomeViewController.h"
#import "ProfileEditController.h"
#import "RecentSparksViewController.h"
#import "Firefeed.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[Crashlytics startWithAPIKey:@"<crashlytics key>"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Quick printout of the various versions and some basic info about the app
    [Firefeed logDiagnostics];

    // Set up some appearances
    UIColor* textColor = [UIColor colorWithRed:0x7b / 255.0f green:0x5f / 255.0f blue:0x11 / 255.0f alpha:1.0f];
    UIColor* mediumYellow = [UIColor colorWithRed:0xff / 255.0f green:0xea / 255.0f blue:0xb3 / 255.0f alpha:1.0];
    UIColor* brownColor = [UIColor colorWithRed:0x7b / 255.0f green:0x5f / 255.0f blue:0x11 / 255.0f alpha:1.0f];
    [[UINavigationBar appearance] setTintColor:mediumYellow];
    [[UITabBar appearance] setSelectedImageTintColor:mediumYellow];
    [[UITabBar appearance] setTintColor:brownColor];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor: textColor, UITextAttributeTextShadowColor: [UIColor clearColor]} forState:UIControlStateNormal];


    UITabBarController* tabBarController = [[UITabBarController alloc] init];

    HomeViewController* homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:homeViewController];

    ProfileEditController* profileEditController = [[ProfileEditController alloc] initWithNibName:@"ProfileEditController" bundle:nil];
    UINavigationController* profileNavController = [[UINavigationController alloc] initWithRootViewController:profileEditController];

    RecentSparksViewController* recentSparksController = [[RecentSparksViewController alloc] initWithNibName:@"RecentSparksViewController" bundle:nil];
    UINavigationController* recentNavController = [[UINavigationController alloc] initWithRootViewController:recentSparksController];

    tabBarController.viewControllers = @[navController, profileNavController, recentNavController];
    self.window.rootViewController = tabBarController;

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    return [TencentOAuth HandleOpenURL:url];
    
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url];
}


@end

















