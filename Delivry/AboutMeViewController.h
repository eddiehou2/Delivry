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

@property (weak, nonatomic) IBOutlet UIImageView *thrumbnailImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
- (IBAction)notificationButton:(id)sender;
- (IBAction)messageButton:(id)sender;




- (void)loggedInWith:(PFUser *) user;

@end
