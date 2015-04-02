//
//  AddPaymentCardViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-10.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "AddPaymentCardViewController.h"
#import <Parse/Parse.h>
#import "Stripe.h"

@interface AddPaymentCardViewController () <UITextFieldDelegate>

@end

@implementation AddPaymentCardViewController {
    BOOL cardNumberCorrectLength;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.cardNumber addTarget:self
                  action:@selector(cardNumberDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    [self.expireDate addTarget:self action:@selector(expireDateDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.cvv addTarget:self action:@selector(cvvDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(savePaymentCard:)];
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
    cardNumberCorrectLength = false;
    if (self.cardNumber.text.length <= 2) {
        UIImage *blankCard = [UIImage imageNamed:@""];
        self.cardType = @"NONE";
        self.cardImage.image = blankCard;
    }
    if ([self.cardNumber.text hasPrefix:@"4"]) {
        UIImage *visaCard = [UIImage imageNamed:@"visaLogo"];
        self.cardType = @"VISA";
        self.cardImage.image = visaCard;
        if (self.cardNumber.text.length == 4 || self.cardNumber.text.length == 9 || self.cardNumber.text.length == 14) {
            [self cardNumberInsertSpaceOrNot];
        }
        else if (self.cardNumber.text.length == 5 || self.cardNumber.text.length == 10 || self.cardNumber.text.length == 15) {
            [self cardNumberRemoveSpaceOrNot];
        }
        
        if (self.cardNumber.text.length == 16 || self.cardNumber.text.length == 19) {
            cardNumberCorrectLength = true;
        }
    }
    else if ([self.cardNumber.text hasPrefix:@"34"] || [self.cardNumber.text hasPrefix:@"37"]) {
        UIImage *americanExpressCard = [UIImage imageNamed:@"americanExpressLogo"];
        self.cardType = @"AMERICANEXPRESS";
        self.cardImage.image = americanExpressCard;
        if (self.cardNumber.text.length == 4 || self.cardNumber.text.length == 11) {
            [self cardNumberInsertSpaceOrNot];
        }
        else if (self.cardNumber.text.length == 5 || self.cardNumber.text.length == 12) {
            [self cardNumberRemoveSpaceOrNot];
        }
        
        if (self.cardNumber.text.length == 17) {
            cardNumberCorrectLength = true;
        }
    }
    else {
        UIImage *mastercardCard = [UIImage imageNamed:@"mastercardLogo"];
        self.cardType = @"MASTERCARD";
        self.cardImage.image = mastercardCard;
        if (self.cardNumber.text.length == 4 || self.cardNumber.text.length == 9 || self.cardNumber.text.length == 14) {
            [self cardNumberInsertSpaceOrNot];
        }
        else if (self.cardNumber.text.length == 5 || self.cardNumber.text.length == 10 || self.cardNumber.text.length == 15) {
            [self cardNumberRemoveSpaceOrNot];
        }
        
        if (self.cardNumber.text.length == 19) {
            cardNumberCorrectLength = true;
        }
    }
    
    self.previousCardNumberLength = self.cardNumber.text.length;
    [self checkForSaveEnabled];
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
    if (self.expireDate.text.length==1) {
        if ([self.expireDate.text integerValue] > 1) {
            self.expireDate.text = @"";
        }
    }
    else if (self.expireDate.text.length==2) {
        if ([self.expireDate.text integerValue] > 12 || [self.expireDate.text integerValue] < 1) {
            self.expireDate.text = [self.expireDate.text substringToIndex:1];
        }
        else if (self.previousExpireDateLength < self.expireDate.text.length) {
            NSLog(@"previous: %li //now: %li",self.previousExpireDateLength,self.expireDate.text.length);
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
    else if (self.expireDate.text.length >= 6) {
        self.expireDate.text = [self.expireDate.text substringToIndex:5];
    }
    
    self.previousExpireDateLength = self.expireDate.text.length;
    [self checkForSaveEnabled];
}

- (void)cvvDidChange:(id)sender {
    if (self.cvv.text.length >=4) {
        self.cvv.text = [self.cvv.text substringToIndex:3];
    }
    
    [self checkForSaveEnabled];
}

- (void)checkForSaveEnabled {
    if (self.cvv.text.length == 3 && self.expireDate.text.length == 5 && cardNumberCorrectLength) {
        self.saveBarButtonItem.enabled = YES;
    }
    else {
        self.saveBarButtonItem.enabled = NO;
    }
}

//- (void)saveUserPaymentInformation:(id)sender {
//    PFObject *userPaymentInfoObject = [PFObject objectWithClassName:@"UserPaymentInfo"];
//    [userPaymentInfoObject setObject:self.cardType forKey:@"cardType"];
//    [userPaymentInfoObject setObject:[self.cardNumber.text substringFromIndex:self.cardNumber.text.length - 4] forKey:@"cardNumber"];
//    [userPaymentInfoObject setObject:self.expireDate.text forKey:@"expiryDate"];
//    [userPaymentInfoObject setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
//    [userPaymentInfoObject setACL:[PFACL ACLWithUser:[PFUser currentUser]]];
//    [userPaymentInfoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            NSLog(@"Info (Parse): Successfully created user payment information.");
//            [self returnToPaymentViewController];
//        }
//        else {
//            NSLog(@"Error (Parse): %@",error);
//        }
//    }];
//}

- (void)savePaymentCard:(id)sender {
    STPCard *card = [[STPCard alloc] init];
    NSLog(@"CHECKING ALL PARAMS TO SEE NIL: cardNumber:: %@ // expMonth:: %ld // expYear:: %ld // cvv:: %@",[self.cardNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""],(long)[[self.expireDate.text substringToIndex:2] integerValue],2000 + [[self.expireDate.text substringFromIndex:3] integerValue],self.cvv.text);
    
    card.number = [self.cardNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    card.expMonth = [[self.expireDate.text substringToIndex:2] integerValue];
    card.expYear = 2000 + [[self.expireDate.text substringFromIndex:3] integerValue];
    card.cvc = self.cvv.text;
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (!error) {
            NSLog(@"CHECKING ALL PARAMS TO SEE NIL: TOKEN:: %@ // USER:: %@",token,[PFUser currentUser]);
            [PFCloud callFunctionInBackground:@"createCustomer" withParameters:@{@"token":token.tokenId,@"user":[PFUser currentUser].objectId,@"cardType":self.cardType,@"cardNumber":[self.cardNumber.text substringFromIndex:self.cardNumber.text.length - 4],@"expiryDate":self.expireDate.text} block:^(id object, NSError *error) {
                if (!error) {
                    NSLog(@"NICE!");
                    
                    //[self saveUserPaymentInformation:nil];
                    [self returnToPaymentViewController];
                }
                else {
                    NSLog(@"FUCK! Error: %@", error);
                }
            }];
        }
        else {
            NSLog(@"Error (Stripe): %@",error);
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
