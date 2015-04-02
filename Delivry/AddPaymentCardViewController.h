//
//  AddPaymentCardViewController.h
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-10.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPaymentCardViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *cardImage;
@property (weak, nonatomic) IBOutlet UITextField *cardNumber;
@property (weak, nonatomic) IBOutlet UITextField *expireDate;
@property (weak, nonatomic) IBOutlet UITextField *cvv;

@property (assign, nonatomic) long previousCardNumberLength;
@property (strong, nonatomic) UIBarButtonItem *saveBarButtonItem;
@property (assign, nonatomic) long previousExpireDateLength;

@property (nonatomic, strong) NSString *cardType;
@end
