//
//  AppDelegate.m
//  Delivry
//
//  Created by Eddie Hou on 2014-11-24.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "Stripe.h"
#import "CartViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <GoogleMaps/GoogleMaps.h>

NSString * const StripePulishableKey = @"pk_test_iUwDnl65TdaFBlYpfAnQfPzP";
NSString * const ParseApplicationID = @"hBa1XUtZDS7CVVvq03VVPSqd1umCPPFrPNsangKi";
NSString * const ParseClientKey = @"hACU5cMTXFb8DNDVfnDi9hsmJYHnPj5kfZXat5iN";
NSString * const GoogleMapAPIKey = @"AIzaSyCzdXSESxSJATrkF3y_WmdcIos_seuIoHY";

@interface AppDelegate () 

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:ParseApplicationID
                  clientKey:ParseClientKey];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    
    [GMSServices provideAPIKey:GoogleMapAPIKey];
    [Stripe setDefaultPublishableKey:StripePulishableKey];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.tabBarController = [[UITabBarController alloc] init];
    UINavigationController *navigationController3 = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"aboutMeViewController"]];
    navigationController3.title = @"About Me";
    navigationController3.navigationBar.topItem.title = @"About Me";

    UINavigationController *navigationController2 = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"mapViewController"]];
    navigationController2.title = @"Map";
    navigationController2.navigationBar.topItem.title = @"Map";
    
    UINavigationController *navigationController1 = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"homeViewController"]];
    navigationController1.title = @"Home";
    navigationController1.navigationBar.topItem.title = @"Home";
    
    NSArray *controllers = [NSArray arrayWithObjects:navigationController1,navigationController2,navigationController3, nil];
    self.tabBarController.viewControllers = controllers;
    
    
    
    //[self.window setRootViewController:self.tabBarController];
    
    
    //TESTING PURPOSE ONLY
    CartViewController *cartViewController = [[CartViewController alloc] init];
    [self.window setRootViewController:cartViewController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PFFacebookUtils session] close];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession: [PFFacebookUtils session]];
    
}



@end
