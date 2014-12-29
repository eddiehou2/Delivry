//
//  AppDelegate.h
//  Delivry
//
//  Created by Eddie Hou on 2014-11-24.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet HomeViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;


@end

