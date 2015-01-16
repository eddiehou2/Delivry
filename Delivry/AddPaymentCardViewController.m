//
//  AddPaymentCardViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-10.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "AddPaymentCardViewController.h"
#import <Parse/Parse.h>

@interface AddPaymentCardViewController () <UITextFieldDelegate>

@end

@implementation AddPaymentCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.cardNumber addTarget:self
                  action:@selector(cardNumberDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    self.saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveUserPaymentInformation:)];
    self.saveBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.saveBarButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@"1234 5678 9012 3456"]) {
        textField.text = @"";
        textField.textColor = [UIColor blackColor]; //optional
    }
    [textField becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.cardNumber) {
        if ([textField.text isEqualToString:@""]) {
            textField.text = @"1234 5678 9012 3456";
            textField.textColor = [UIColor lightGrayColor]; //optional
        }
    }
    [textField resignFirstResponder];
}

- (void)cardNumberDidChange:(id)sender {
    if (self.cardNumber.text.length <= 2) {
        UIImage *blankCard = [UIImage imageNamed:@""];
        self.cardImage.image = blankCard;
    }
    if ([self.cardNumber.text hasPrefix:@"4"]) {
        UIImage *visaCard = [UIImage imageNamed:@"visaLogo"];
        self.cardImage.image = visaCard;
        if (self.cardNumber.text.length == 4 || self.cardNumber.text.length == 9 || self.cardNumber.text.length == 14) {
            [self cardNumberInsertSpaceOrNot];
        }
        else if (self.cardNumber.text.length == 5 || self.cardNumber.text.length == 10 || self.cardNumber.text.length == 15) {
            [self cardNumberRemoveSpaceOrNot];
        }
        
        if (self.cardNumber.text.length == 16 || self.cardNumber.text.length == 19) {
            // enable expire date
            self.saveBarButtonItem.enabled = YES;
        }
        else {
            // disable expire date
            self.saveBarButtonItem.enabled = NO;
        }
    }
    else if ([self.cardNumber.text hasPrefix:@"34"] || [self.cardNumber.text hasPrefix:@"37"]) {
        UIImage *americanExpressCard = [UIImage imageNamed:@"americanExpressLogo"];
        self.cardImage.image = americanExpressCard;
        if (self.cardNumber.text.length == 4 || self.cardNumber.text.length == 11) {
            [self cardNumberInsertSpaceOrNot];
        }
        else if (self.cardNumber.text.length == 5 || self.cardNumber.text.length == 12) {
            [self cardNumberRemoveSpaceOrNot];
        }
        
        if (self.cardNumber.text.length == 17) {
            // enable expire date
            self.saveBarButtonItem.enabled = YES;
        }
        else {
            // disable expire date
            self.saveBarButtonItem.enabled = NO;
        }
    }
    else {
        UIImage *mastercardCard = [UIImage imageNamed:@"mastercardLogo"];
        self.cardImage.image = mastercardCard;
        if (self.cardNumber.text.length == 4 || self.cardNumber.text.length == 9 || self.cardNumber.text.length == 14) {
            [self cardNumberInsertSpaceOrNot];
        }
        else if (self.cardNumber.text.length == 5 || self.cardNumber.text.length == 10 || self.cardNumber.text.length == 15) {
            [self cardNumberRemoveSpaceOrNot];
        }
        
        if (self.cardNumber.text.length == 19) {
            //enable expire date
            self.saveBarButtonItem.enabled = YES;
        }
        else {
            // disable expire date
            self.saveBarButtonItem.enabled = NO;
        }
    }
    self.previousCardNumberLength = self.cardNumber.text.length;
}

- (void)cardNumberInsertSpaceOrNot {
    if (self.previousCardNumberLength < self.cardNumber.text.length) {
        self.cardNumber.text = [NSString stringWithFormat:@"%@ ",self.cardNumber.text];
    }
}

- (void)cardNumberRemoveSpaceOrNot {
    if (self.previousCardNumberLength > self.cardNumber.text.length) {
        self.cardNumber.text = [self.cardNumber.text substringToIndex:self.cardNumber.text.length-1];
    }
    else {
        self.cardNumber.text = [NSString stringWithFormat:@"%@ %@",[self.cardNumber.text substringToIndex:self.cardNumber.text.length-1],[self.cardNumber.text substringFromIndex:self.cardNumber.text.length-1]];
    }
}

- (void)expireDateDidChange:(id)sender {
    if (self.expireDate.text.length == 2) {
        if (self.previousExpireDateLength < self.expireDate.text.length) {
            self.expireDate.text = [NSString stringWithFormat:@"%@/",self.expireDate.text];
        }
    }
    else if (self.expireDate.text.length == 3) {
        if (self.previousExpireDateLength > self.expireDate.text.length) {
            self.expireDate.text = [self.expireDate.text substringToIndex:self.expireDate.text.length - 1];
        }
        else {
            self.expireDate.text = [NSString stringWithFormat:@"%@/%@",[self.expireDate.text substringToIndex:self.expireDate.text.length - 1],[self.expireDate.text substringFromIndex:self.expireDate.text.length - 1]];
        }
    }
    
    if ([[self.expireDate.text substringToIndex:1] integerValue] == 1) {
        // second digit has to be 0,1 or 2 => <13
    }
    else if ([[self.expireDate.text substringToIndex:1] integerValue] == 0) {
        // second digit has to be 1 - 9 => < 10 and > 0
    }
    else {
        self.expireDate.text = @"";
    }
    
    if ([[self.expireDate.text substringFromIndex:4] integerValue] >= 15) {
        self.expireDate.text = @"";
    }
}

- (void)saveUserPaymentInformation:(id)sender {
    PFObject *userPaymentInfoObject = [PFObject objectWithClassName:@"UserPaymentInfo"];
    [userPaymentInfoObject setObject:self.cardType forKey:@"cardType"];
    [userPaymentInfoObject setObject:[self.cardNumber.text substringFromIndex:self.cardNumber.text.length - 4] forKey:@"cardNumber"];
    [userPaymentInfoObject setObject:self.expireDate.text forKey:@"expiryDate"];
    [userPaymentInfoObject setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
    [userPaymentInfoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Info (Parse): Successfully created user payment information.");
            [self savePaymentCard:userPaymentInfoObject];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

- (void)savePaymentCard:(PFObject *)userPaymentInfoObject {
    PFObject *paymentCardObject = [PFObject objectWithClassName:@"PaymentCards"];
    [paymentCardObject setObject:[self.cardNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"cardNumber"];
    [paymentCardObject setObject:[self.expireDate.text substringFromIndex:3] forKey:@"expiryYear"];
    [paymentCardObject setObject:[self.expireDate.text substringToIndex:2] forKey:@"expiryMonth"];
    // CVV?
    [paymentCardObject setObject:userPaymentInfoObject forKey:@"paymentCard"];
    [paymentCardObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Info (Parse): Successfully created payment card.");
            [self returnToPaymentViewController];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

- (void)returnToPaymentViewController {
    [self.navigationController popViewControllerAnimated:YES];
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
