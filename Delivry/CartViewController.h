//
//  CartViewController.h
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-13.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;

@interface CartViewController : UIViewController

@property(nonatomic,strong) PFObject *restaurantName;
@property(nonatomic,strong) NSMutableArray *restaurantItems;
@property(nonatomic,strong) NSMutableArray *cartItems;
@property(nonatomic,strong) UIScrollView *scrollView;

@property(nonatomic,assign) long yPosition;

@end
