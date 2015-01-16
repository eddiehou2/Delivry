//
//  PaymentViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-12.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "PaymentViewController.h"
#import "AddPaymentCardViewController.h"
#import <Parse/Parse.h>

@interface PaymentViewController ()

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addPaymentCard:)];
    self.navigationItem.rightBarButtonItem = add;
    
    for (PFObject *object in self.paymentCards) {
        NSString *cardType = [object objectForKey:@"cardType"];
        NSString *cardNumber = [object objectForKey:@"cardNumber"];
        NSString *expiryDate = [object objectForKey:@"expiryDate"];
        BOOL selected = [object objectForKey:@"selected"];
        [self createPaymentCardCellWithCardType:cardType cardNumber:cardNumber expiryDate:expiryDate selected:selected];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createPaymentCardCellWithCardType:(NSString *)cardType cardNumber:(NSString *)cardNumber expiryDate:(NSString *)expiryDate selected:(BOOL)selected {
    long delta = self.paymentCardCells.count*60 + 44;
    UIButton *paymentCard = [UIButton buttonWithType:UIButtonTypeCustom];
    paymentCard.frame = CGRectMake(0, delta, self.view.frame.size.width, 60);
    
    // Added payment card image view
    UIImageView *paymentCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 40, 40)];
    paymentCardImageView.image = [UIImage imageNamed:cardType];
    [paymentCard addSubview:paymentCardImageView];
    
    // Added selected image view
    UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(paymentCard.frame.size.width-45, 5, 40, 40)];
    if (selected) {
        selectedImageView.image = [UIImage imageNamed:@"selected"];
    }
    [paymentCard addSubview:selectedImageView];
    
    // Added card number label
    UILabel *cardNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, paymentCard.frame.size.width-100, paymentCard.frame.size.width/2)];
    cardNumberLabel.font = [UIFont systemFontOfSize:18];
    cardNumberLabel.text = cardNumber;
    [paymentCard addSubview:cardNumberLabel];
    
    // Added expiry date label
    UILabel *expiryDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, paymentCard.frame.size.width/2, paymentCard.frame.size.width-100, paymentCard.frame.size.width/2)];
    expiryDateLabel.font = [UIFont systemFontOfSize:14];
    expiryDateLabel.text = expiryDate;
    [paymentCard addSubview:expiryDateLabel];
    
    paymentCard.tag = self.paymentCardCells.count;
    [paymentCard addTarget:self action:@selector(selectPaymentCard:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:paymentCard];
    [self.paymentCardCells addObject:paymentCard];
}

- (void)selectPaymentCard:(id)sender {
    UIButton *currentButton = (UIButton *)sender;
    PFObject *selectedPaymentCard = [self.paymentCards objectAtIndex:currentButton.tag];
    for (PFObject *object in self.paymentCards) {
        if ([object objectForKey:@"selected"]) {
            [object setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Info (Parse): Successfully unselected a card for payment.");
                }
                else {
                    NSLog(@"Error (Parse): %@", error);
                }
            }];
        }
    }
    
    [selectedPaymentCard setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
    [selectedPaymentCard saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Info (Parse): Successfully selected a card for payment.");
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

- (void)addPaymentCard:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddPaymentCardViewController *addPaymentCardViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"addPaymentCardViewController"];
    [self.navigationController pushViewController:addPaymentCardViewController animated:YES];
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
