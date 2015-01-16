//
//  AccountViewController.h
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-11.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFUser;

@interface AccountViewController : UIViewController

@property (nonatomic,strong) PFUser *user;

@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *userTitle;

@property (nonatomic,weak) IBOutlet UILabel *nameLabel;
@property (nonatomic,weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;

@property (nonatomic,weak) IBOutlet UIButton *accountInformationButton;
@property (nonatomic,weak) IBOutlet UIButton *paymentButton;
@property (nonatomic,weak) IBOutlet UIButton *addressButton;
@property (nonatomic,weak) IBOutlet UIButton *orderHistoryButton;

@property (nonatomic,weak) IBOutlet UIButton *contactUsButton;
@property (nonatomic,weak) IBOutlet UIButton *freeDelivryButton;
@property (nonatomic,weak) IBOutlet UIButton *becomeDelivrerButton;

@property (nonatomic,weak) IBOutlet UIButton *logOutButton;

@end
