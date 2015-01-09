//
//  RestaurantDetailViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-12-27.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import "MainViewController.h"
#import "Stripe.h"
#import <Parse/Parse.h>

@interface RestaurantDetailViewController ()

@end

@implementation RestaurantDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.image.image = [UIImage imageNamed:@"app_icon"];
    self.nameLabel.text = [self.restaurant objectForKey:@"restaurantName"];
    self.descriptionLabel.text = [self.restaurant objectForKey:@"restaurantDescription"];
    self.priceLabel.text = [NSString stringWithFormat:@"%@/5",[self.restaurant objectForKey:@"restaurantPrice"]];
    self.minimumLabel.text = [NSString stringWithFormat:@"$%@+",[self.restaurant objectForKey:@"restaurantMinimum"]];
    PFGeoPoint *point = [PFGeoPoint geoPointWithLocation:self.currentLocation];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f km",[point distanceInKilometersTo:[self.restaurant objectForKey:@"restaurantLocation"]]];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"RestaurantItems"];
    [query whereKey:@"restaurant" equalTo:self.restaurant];
    self.restaurantItems = [[query findObjects] mutableCopy];
    self.quantity = [[NSMutableArray alloc] init];
    
    NSInteger noItems = self.restaurantItems.count;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.image.bounds.size.height + self.navigationController.navigationBar.frame.size.height + 10, self.view.bounds.size.width, self.view.bounds.size.height-(self.image.bounds.size.height + self.navigationController.navigationBar.frame.size.height + self.tabBarController.tabBar.frame.size.height + 10))];
    [scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width, noItems*25 + 40)];
    for (int i = 0; i < noItems; i++) {
        PFObject *restaurantItem = self.restaurantItems[i];
        UILabel *item = [[UILabel alloc] initWithFrame:CGRectMake(10, i*25, (3/4.0)*(scrollView.bounds.size.width - 10), 21)];
        item.text = [NSString stringWithFormat:@"%@",[restaurantItem objectForKey:@"itemName"]];
        item.tag=4 * i;
        [scrollView addSubview:item];
        
        UILabel *quantity = [[UILabel alloc] initWithFrame:CGRectMake((3/4.0)*(scrollView.bounds.size.width - 10)+10+50, i*25, (1/4.0)*(scrollView.bounds.size.width - 10)-50, 21)];
        quantity.text = @"0";
        quantity.tag=4 * i + 1;
        [scrollView addSubview:quantity];
        [self.quantity addObject:quantity];
        
        UIButton *add = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        add.frame = CGRectMake((3/4.0)*(scrollView.bounds.size.width - 10)+10, i*25, 21, 21);
        [add setTitle:@"+" forState:UIControlStateNormal];
        add.tag=4 * i + 2;
        [add addTarget:self action:@selector(increaseItemQuantity:) forControlEvents:UIControlEventTouchUpInside];
        add.enabled = YES;
        [scrollView addSubview:add];
        
        UIButton *minus = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        minus.frame = CGRectMake((3/4.0)*(scrollView.bounds.size.width - 10)+10+25, i*25, 21, 21);
        [minus setTitle:@"-" forState:UIControlStateNormal];
        minus.tag=4 * i + 3;
        [minus addTarget:self action:@selector(decreaseItemQuantity:) forControlEvents:UIControlEventTouchUpInside];
        minus.enabled = NO;
        [scrollView addSubview:minus];
    }
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submit.frame = CGRectMake(scrollView.bounds.size.width - 110, noItems*25+5, 100, 30);
    [submit setTitle:@"Submit" forState:UIControlStateNormal];
    [scrollView addSubview:submit];
    
    [self.view addSubview:scrollView];
    
    [submit addTarget:self action:@selector(submitOrder:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) increaseItemQuantity:(id) sender{
    UIButton *add = (UIButton *) sender;
    UILabel *label = (UILabel *) [self.view viewWithTag:(add.tag-1)];
    label.text = [NSString stringWithFormat:@"%i",([label.text intValue]+1)];
    if ([label.text intValue] > 0) {
        UIButton *minus = (UIButton *) [self.view viewWithTag:(add.tag+1)];
        minus.enabled = YES;
    }
}

-(void) decreaseItemQuantity:(id) sender{
    UIButton *minus = (UIButton *) sender;
    UILabel *label = (UILabel *) [self.view viewWithTag:(minus.tag-2)];
    label.text = [NSString stringWithFormat:@"%i",([label.text intValue]-1)];
    if ([label.text intValue] < 1) {
        minus.enabled = NO;
    }
}


-(void) submitOrder:(id) sender {
    if ([PFUser currentUser] != nil) {
        [self createBundle];
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No User" message:@"An user must be logged on to use the Delivry feature of the app. Please login and try again." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *login = [UIAlertAction actionWithTitle:@"Log In" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MainViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainViewController"];
            [self presentViewController:mainViewController animated:YES completion:nil];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:login];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void) createBundle {
    // Create a bundle for the order
    PFObject *bundleObject = [PFObject objectWithClassName:@"Bundles"];
    [bundleObject setObject:self.restaurant forKey:@"restaurant"];
    [bundleObject setObject:[NSDate date] forKey:@"delivryBy"];
    [bundleObject setObject:[PFGeoPoint geoPointWithLocation:self.currentLocation] forKey:@"delivryTo"];
    [bundleObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"createdBundle? %@",succeeded ? @"Yes" : @"No");
        if (succeeded) {
            [self createTransaction:bundleObject];
            NSLog(@"Info (Parse): Bundle Object has been successfully created.");
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

-(void) createTransaction:(PFObject *)bundleObject {
    PFObject *transactionObject = [PFObject objectWithClassName:@"Transactions"];
    [transactionObject setObject:bundleObject forKey:@"bundle"];
    [transactionObject setObject:[PFUser currentUser] forKey:@"user"];
    [transactionObject setObject:[PFGeoPoint geoPointWithLocation:self.currentLocation] forKey:@"delivryLocation"];
    [transactionObject setObject:@"Address goes here" forKey:@"delivryAddress"];
    [transactionObject setObject:[NSNumber numberWithBool:NO] forKey:@"charged"];
    [transactionObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self createOrder:transactionObject];
            NSLog(@"Info (Parse): Transaction Object has been successfully created.");
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

-(void) createOrder:(PFObject *)transactionObject {
    NSMutableArray *orderItems = [[NSMutableArray alloc] init];
    double totalPrice = 0.00;
    // Create a list of OrderItems
    for (int i = 0; i < self.restaurantItems.count; i++) {
        UILabel *quantityLabel = self.quantity[i];
        PFObject *restaurantItem = self.restaurantItems[i];
        if (![quantityLabel.text isEqual: @"0"]) {
            NSNumber *quantity = [[NSNumber alloc] initWithInt:[quantityLabel.text intValue]];
            
            PFObject *orderItem = [PFObject objectWithClassName:@"OrderItems"];
            [orderItem setObject:transactionObject forKey:@"transaction"];
            [orderItem setObject:restaurantItem forKey:@"orderedItem"];
            [orderItem setObject:quantity forKey:@"quantity"];
            [orderItems addObject:orderItem];
            
            totalPrice += [quantity intValue] * [[restaurantItem objectForKey:@"itemPrice"] floatValue];
        }
    }
    [PFObject saveAllInBackground:orderItems block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Info (Parse): Order Items have been successfully saved.");
            NSLog(@"Total Price: %f", totalPrice);
            [self createPayment:transactionObject withAmount:totalPrice];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

-(void) createPayment:(PFObject *)transactionObject withAmount:(double) totalPrice {
    STPCard *card = [[STPCard alloc] init];
    card.number = @"4242424242424242";
    card.expMonth = 5;
    card.expYear = 2015;
    card.cvc = @"969";
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (!error) {
            NSLog(@"Token: %@",token);
            [PFCloud callFunctionInBackground:@"orderedItems" withParameters:@{@"totalPrice":[[NSNumber alloc] initWithDouble:(ceil(totalPrice*100)/100)],@"currency":@"cad",@"cardToken":[token tokenId],@"name":@"Name Goes Here Later",@"email":@"Email Goes Here Later",@"address":@"Address Goes Here Later",@"city_province":@"City Province Goes Here Later",@"zip":@"Zip Goes Here Later",@"transactionID":transactionObject.objectId} block:^(id object, NSError *error) {
                if (!error) {
                    NSLog(@"Info (Stripe): A charge of %.2f has been successfully charged.",totalPrice);
                }
                else {
                    NSLog(@"Error (Stripe): %@",error);
                }
            }];
        }
        else {
            NSLog(@"Error (Stripe): %@",error);
        }
    }];
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
