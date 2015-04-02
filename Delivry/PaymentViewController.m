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

const int STATUSBARHEIGHT = 20;
const int CELLHEIGHT = 60;

@interface PaymentViewController ()

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addPaymentCard:)];
    self.navigationItem.rightBarButtonItem = add;
}

- (void)viewDidAppear:(BOOL)animated {
    [self reloadPaymentCardsData];
}

- (void)reloadPaymentView {
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor = [UIColor whiteColor];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, STATUSBARHEIGHT+self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-(STATUSBARHEIGHT+self.navigationController.navigationBar.frame.size.height+self.tabBarController.tabBar.frame.size.height))];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.paymentCards.count*CELLHEIGHT);
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    self.paymentCardCells = [[NSMutableArray alloc] init];
    
    
    for (PFObject *object in self.paymentCards) {
        NSString *cardType = [object objectForKey:@"cardType"];
        NSString *cardNumber = [object objectForKey:@"cardNumber"];
        NSString *expiryDate = [object objectForKey:@"expiryDate"];
        BOOL selected = [[object objectForKey:@"selected"] boolValue];
        [self createPaymentCardCellWithCardType:cardType cardNumber:cardNumber expiryDate:expiryDate selected:selected];
    }
}

- (void)reloadPaymentCardsData {
    PFQuery *query = [PFQuery queryWithClassName:@"UserPaymentInfo"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.paymentCards = [objects mutableCopy];
            NSLog(@"Info (Parse): Successfully reloaded payment information.");
            [self reloadPaymentView];
        }
        else {
            NSLog(@"Error (Parse): %@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createPaymentCardCellWithCardType:(NSString *)cardType cardNumber:(NSString *)cardNumber expiryDate:(NSString *)expiryDate selected:(BOOL)selected {
    long delta = self.paymentCardCells.count*CELLHEIGHT;
    UIButton *paymentCard = [UIButton buttonWithType:UIButtonTypeCustom];
    paymentCard.frame = CGRectMake(0, delta, self.scrollView.frame.size.width, CELLHEIGHT);
    paymentCard.backgroundColor = [UIColor lightGrayColor];
    
    // Added payment card image view
    UIImageView *paymentCardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 40, 40)];
    paymentCardImageView.image = [UIImage imageNamed:cardType];
    paymentCardImageView.backgroundColor = [UIColor purpleColor];
    [paymentCard addSubview:paymentCardImageView];
    
    // Added selected image view
    UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(paymentCard.frame.size.width-45, 10, 40, 40)];
    if (selected) {
        paymentCard.backgroundColor = [UIColor whiteColor];
        selectedImageView.image = [UIImage imageNamed:@"selected"];
    }
    selectedImageView.backgroundColor = [UIColor greenColor];
    [paymentCard addSubview:selectedImageView];
    
    // Added card number label
    UILabel *cardNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, paymentCard.frame.size.width-100, (paymentCard.frame.size.height-20)/2)];
    cardNumberLabel.font = [UIFont boldSystemFontOfSize:20];
    cardNumberLabel.text = [NSString stringWithFormat:@"%@ **** %@",cardType,cardNumber];
    [paymentCard addSubview:cardNumberLabel];
    
    // Added expiry date label
    UILabel *expiryDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, paymentCard.frame.size.height/2, paymentCard.frame.size.width-100, (paymentCard.frame.size.height-20)/2)];
    expiryDateLabel.font = [UIFont boldSystemFontOfSize:14];
    expiryDateLabel.text = expiryDate;
    [paymentCard addSubview:expiryDateLabel];
    
    paymentCard.tag = self.paymentCardCells.count;
    [paymentCard addTarget:self action:@selector(selectPaymentCard:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:paymentCard];
    [self.paymentCardCells addObject:paymentCard];
}

- (void)selectPaymentCard:(id)sender {
    for (PFObject *object in self.paymentCards) {
        if ([object objectForKey:@"selected"]) {
            [object setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        }
    }
    
    UIButton *currentButton = (UIButton *)sender;
    PFObject *selectedPaymentCard = [self.paymentCards objectAtIndex:currentButton.tag];
    [selectedPaymentCard setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
    
    [PFObject saveAllInBackground:self.paymentCards block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Info (Parse): Successfully changed selected card.");
            [self reloadPaymentCardsData];
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
