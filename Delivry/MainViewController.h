//
//  ViewController.h
//  Delivry
//
//  Created by Eddie Hou on 2014-11-24.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AboutMeViewController;
@class PFUser;

@interface MainViewController : UIViewController

@property(nonatomic,weak) AboutMeViewController *aboutMeViewController;
- (IBAction)handleFacebookLogin:(id)sender;
- (void)redirectToHome: (PFUser *) user;
@end

