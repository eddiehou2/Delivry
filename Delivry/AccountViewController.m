//
//  AccountViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-11.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "AccountViewController.h"
#import "PFUser+CurrentInformation.h"
#import "PaymentViewController.h"
#import "AddressViewController.h"
#import "OrderHistoryViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [PFUser currentUser];
    // Do any additional setup after loading the view.
    
    [self initSubviewsInAccount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubviewsInAccount {
    // Added subviews to accountInformationButton
    UILabel *accountInformationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.accountInformationButton.frame.size.width,self.accountInformationButton.frame.size.height/2)];
    accountInformationLabel.text = @"Account Information";
    accountInformationLabel.font = [UIFont systemFontOfSize:18];
    [self.accountInformationButton addSubview:accountInformationLabel];
    
    UILabel *accountInformationDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.accountInformationButton.frame.size.height/2, self.accountInformationButton.frame.size.width,self.accountInformationButton.frame.size.height-accountInformationLabel.frame.size.height)];
    accountInformationDescriptionLabel.text = @"Edit you account information";
    accountInformationDescriptionLabel.font = [UIFont systemFontOfSize:14];
    [self.accountInformationButton addSubview:accountInformationDescriptionLabel];
    
    // Added subviews to paymentButton
    UILabel *paymentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.paymentButton.frame.size.width,self.paymentButton.frame.size.height/2)];
    paymentLabel.text = @"Payment";
    paymentLabel.font = [UIFont systemFontOfSize:18];
    [self.paymentButton addSubview:paymentLabel];
    
    UILabel *paymentDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.paymentButton.frame.size.height/2, self.paymentButton.frame.size.width,self.paymentButton.frame.size.height-paymentLabel.frame.size.height)];
    paymentDescriptionLabel.text = @"Update payment methods";
    paymentDescriptionLabel.font = [UIFont systemFontOfSize:14];
    [self.paymentButton addSubview:paymentDescriptionLabel];
    
    // Added subviews to addressButton
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.addressButton.frame.size.width,self.addressButton.frame.size.height/2)];
    addressLabel.text = @"Addresses";
    addressLabel.font = [UIFont systemFontOfSize:18];
    [self.addressButton addSubview:addressLabel];
    
    UILabel *addressDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.addressButton.frame.size.height/2, self.addressButton.frame.size.width,self.addressButton.frame.size.height-addressLabel.frame.size.height)];
    addressDescriptionLabel.text = @"Add or remove addresses";
    addressDescriptionLabel.font = [UIFont systemFontOfSize:14];
    [self.addressButton addSubview:addressDescriptionLabel];
    
    // Added subviews to orderHistoryButton
    UILabel *orderHistoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.orderHistoryButton.frame.size.width,self.orderHistoryButton.frame.size.height/2)];
    orderHistoryLabel.text = @"Order History";
    orderHistoryLabel.font = [UIFont systemFontOfSize:18];
    [self.orderHistoryButton addSubview:orderHistoryLabel];
    
    UILabel *orderHistoryDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.orderHistoryButton.frame.size.height/2, self.orderHistoryButton.frame.size.width,self.orderHistoryButton.frame.size.height-orderHistoryLabel.frame.size.height)];
    orderHistoryDescriptionLabel.text = @"View past orders made";
    orderHistoryDescriptionLabel.font = [UIFont systemFontOfSize:14];
    [self.orderHistoryButton addSubview:orderHistoryDescriptionLabel];
    
    // Added subviews to contactUsButton
    UILabel *contactUsLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.contactUsButton.frame.size.width,self.contactUsButton.frame.size.height)];
    contactUsLabel.text = @"Contact Us";
    contactUsLabel.font = [UIFont systemFontOfSize:20];
    [self.contactUsButton addSubview:contactUsLabel];
    
    // Added subviews to freeDelivryButton
    UILabel *freeDelivryLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.freeDelivryButton.frame.size.width,self.freeDelivryButton.frame.size.height)];
    freeDelivryLabel.text = @"Free Delivry";
    freeDelivryLabel.font = [UIFont systemFontOfSize:20];
    [self.freeDelivryButton addSubview:freeDelivryLabel];
    
    // Added subviews to becomeDelivrerButton
    UILabel *becomeDelivrerLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.becomeDelivrerButton.frame.size.width,self.becomeDelivrerButton.frame.size.height)];
    becomeDelivrerLabel.text = @"Become A Delivrer";
    becomeDelivrerLabel.font = [UIFont systemFontOfSize:20];
    [self.becomeDelivrerButton addSubview:becomeDelivrerLabel];
    
    // Added subviews to logOutButton
    UILabel *logOutLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.logOutButton.frame.size.width,self.logOutButton.frame.size.height)];
    logOutLabel.text = @"Log Out";
    logOutLabel.font = [UIFont systemFontOfSize:20];
    [self.logOutButton addSubview:logOutLabel];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"accountInformationSegue"]) {
        
    }
    else if ([segue.identifier isEqualToString:@"paymentSegue"]) {
        
    }
    else if ([segue.identifier isEqualToString:@"addressSegue"]) {
        
    }
    else if ([segue.identifier isEqualToString:@"orderHistorySegue"]) {
        
    }
}


@end
