//
//  AboutMeViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-12-29.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "AboutMeViewController.h"
#import "MainViewController.h"
#import "HomeViewController.h"
#import "PFUser+CurrentInformation.h"
#import "AddPaymentCardViewController.h"
#import "PaymentViewController.h"

@interface AboutMeViewController ()

@end

@implementation AboutMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [PFUser currentUser];
    NSLog(@"%@",self.user);
    if (self.user == nil) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        
        MainViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainViewController"];
        mainViewController.aboutMeViewController = self;
        [self.navigationController pushViewController:mainViewController animated:YES];
    }
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPersonalInformation)];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    //[self loggedInWith:[PFUser getInformationFromCurrentUser]];
    //[self refreshUIWithUserInformation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)notificationButton:(id)sender {
}

- (IBAction)messageButton:(id)sender {
}

- (void)loggedInWith:(PFUser *) user {
    self.user = [PFUser getInformationFromCurrentUser];
}

- (void)refreshUIWithUserInformation {
    self.nameLabel.text = self.user.name;
    self.titleLabel.text = self.user.title;
    self.addressLabel.text = self.user.homeAddress;
    NSLog(@"Appearing!!!");
}

- (void)editPersonalInformation {
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    AddPaymentCardViewController *addPaymentCardViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"addPaymentCardViewController"];
//    [self.navigationController pushViewController:addPaymentCardViewController animated:YES];
    
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] init];
    [self.navigationController pushViewController:paymentViewController animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
