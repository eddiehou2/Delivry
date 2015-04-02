//
//  CheckoutViewController.h
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-17.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;

@interface CheckoutViewController : UIViewController

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) UIView *subtotalView;
@property(nonatomic, strong) PFObject *transactionObject;
@property(nonatomic, strong) UIView *timePickerSubView;
@property(nonatomic, strong) UIView *paymentPickerSubView;

@property(nonatomic, assign) double totalPrice;
@property(nonatomic, strong) NSMutableArray *userPaymentInfo;
@property(nonatomic, strong) NSDate *deliveryTime;

@end
