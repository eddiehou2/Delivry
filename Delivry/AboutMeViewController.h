//
//  AboutMeViewController.h
//  Delivry
//
//  Created by Eddie Hou on 2014-12-29.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class DEUser;

@interface AboutMeViewController : UIViewController

@property (nonatomic, weak) DEUser *user;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;



- (void)loggedInWith:(PFUser *) user;

@end
