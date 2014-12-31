//
//  AboutMeViewController.h
//  Delivry
//
//  Created by Eddie Hou on 2014-12-29.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AboutMeViewController : UIViewController

@property (nonatomic, weak) PFUser *user;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;



- (void)loggedInWith:(PFUser *) user;

@end
