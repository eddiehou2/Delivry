//
//  PaymentViewController.h
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-12.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *paymentCards;
@property (nonatomic, strong) NSMutableArray *paymentCardCells;
@property (nonatomic, strong) UIScrollView *scrollView;

@end
