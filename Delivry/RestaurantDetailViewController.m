//
//  RestaurantDetailViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-12-27.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//
//  Changes Needed:
//  1. Error: Restaurant name/price/distance/rating labels move randomly in Y
//  2. Function: After submit, return to previous page or go to cart page or show number of items in cart with red notification number
//  3. Fix: Add ACL for cart items and transaction when ordering/ Don't need ACL for bundles


#import "RestaurantDetailViewController.h"
#import "MainViewController.h"
#import "Stripe.h"
#import <Parse/Parse.h>
#import "LoadingView.h"

@interface RestaurantDetailViewController ()

@end

@implementation RestaurantDetailViewController

- (void)viewDidLoad {
    self.savedView = self.view;
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    self.view = [[LoadingView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    [self reloadRestaurantDetailItems];
}

- (void)reloadRestaurantDetailItems {
    PFQuery *query = [PFQuery queryWithClassName:@"RestaurantItems"];
    [query whereKey:@"restaurant" equalTo:self.restaurant];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Info (Parse): Successfully retrieved menu items for restaurant.");
            self.restaurantItems = [objects mutableCopy];
            PFQuery *cartQuery = [PFQuery queryWithClassName:@"CartItems"];
            [cartQuery whereKey:@"restaurantItem" containedIn:self.restaurantItems];
            [cartQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    NSLog(@"Info (Parse): Successfully retrieved cart item for restaurant.");
                    self.cartItems = [objects mutableCopy];
                    [self reloadRestaurantDetailView];
                }
                else {
                    NSLog(@"Error (Parse): %@",error);
                }
            }];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

- (void)reloadRestaurantDetailView {
    NSInteger noItems = self.restaurantItems.count;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 10, self.view.bounds.size.width, self.view.bounds.size.height-(self.navigationController.navigationBar.frame.size.height + self.tabBarController.tabBar.frame.size.height + 10))];
    [scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width, self.image.bounds.size.height + noItems*25 + 40)];
    scrollView.alwaysBounceVertical = YES;
    
    [scrollView addSubview:self.savedView];
    
    
    // Do any additional setup after loading the view.
    self.image.image = [UIImage imageNamed:@"app_icon"];
    self.nameLabel.text = [self.restaurant objectForKey:@"restaurantName"];
    self.descriptionLabel.text = [self.restaurant objectForKey:@"restaurantDescription"];
    self.priceLabel.text = [NSString stringWithFormat:@"%@/5",[self.restaurant objectForKey:@"restaurantPrice"]];
    self.minimumLabel.text = [NSString stringWithFormat:@"$%@+",[self.restaurant objectForKey:@"restaurantMinimum"]];
    PFGeoPoint *point = [PFGeoPoint geoPointWithLocation:self.currentLocation];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f km",[point distanceInKilometersTo:[self.restaurant objectForKey:@"restaurantLocation"]]];
    
    self.quantity = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < noItems; i++) {
        PFObject *restaurantItem = self.restaurantItems[i];
        UILabel *item = [[UILabel alloc] initWithFrame:CGRectMake(10, self.image.bounds.size.height + i*25, (3/4.0)*(scrollView.bounds.size.width - 10), 21)];
        item.text = [NSString stringWithFormat:@"%@",[restaurantItem objectForKey:@"itemName"]];
        item.tag=4 * i;
        [scrollView addSubview:item];
        
        UILabel *quantity = [[UILabel alloc] initWithFrame:CGRectMake((3/4.0)*(scrollView.bounds.size.width - 10)+10+50, self.image.bounds.size.height + i*25, (1/4.0)*(scrollView.bounds.size.width - 10)-50, 21)];
        int itemQuantity = 0;
        for (int j = 0; j < self.cartItems.count ; j++) {
            PFObject *cartItem = [self.cartItems objectAtIndex:j];
            PFObject *cartRestaurantItem = [cartItem objectForKey:@"restaurantItem"];
            if ([cartRestaurantItem.objectId isEqualToString:restaurantItem.objectId]) {
                itemQuantity = [[cartItem objectForKey:@"quantity"] intValue];
            }
        }
        quantity.text = [NSString stringWithFormat:@"%i",itemQuantity];
        quantity.tag=4 * i + 1;
        [scrollView addSubview:quantity];
        [self.quantity addObject:quantity];
        
        UIButton *add = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        add.frame = CGRectMake((3/4.0)*(scrollView.bounds.size.width - 10)+10, self.image.bounds.size.height + i*25, 21, 21);
        [add setTitle:@"+" forState:UIControlStateNormal];
        add.tag=4 * i + 2;
        [add addTarget:self action:@selector(increaseItemQuantity:) forControlEvents:UIControlEventTouchUpInside];
        add.enabled = ([quantity.text intValue] < 100);
        [scrollView addSubview:add];
        
        UIButton *minus = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        minus.frame = CGRectMake((3/4.0)*(scrollView.bounds.size.width - 10)+10+25, self.image.bounds.size.height + i*25, 21, 21);
        [minus setTitle:@"-" forState:UIControlStateNormal];
        minus.tag=4 * i + 3;
        [minus addTarget:self action:@selector(decreaseItemQuantity:) forControlEvents:UIControlEventTouchUpInside];
        minus.enabled = ([quantity.text intValue] > 0);
        [scrollView addSubview:minus];
    }
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submit.frame = CGRectMake(scrollView.bounds.size.width - 110, self.image.bounds.size.height + noItems*25+5, 100, 30);
    [submit setTitle:@"Submit" forState:UIControlStateNormal];
    [scrollView addSubview:submit];
    
    [self.view addSubview:scrollView];
    
    [submit addTarget:self action:@selector(submitOrder:) forControlEvents:UIControlEventTouchUpInside];
    
    self.view = scrollView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) increaseItemQuantity:(id) sender{
    UIButton *add = (UIButton *) sender;
    UIButton *minus = (UIButton *) [self.view viewWithTag:(add.tag+1)];
    UILabel *label = (UILabel *) [self.view viewWithTag:(add.tag-1)];
    label.text = [NSString stringWithFormat:@"%i",([label.text intValue]+1)];
    minus.enabled = ([label.text intValue] > 0);
    add.enabled = ([label.text intValue] < 100);
}

-(void) decreaseItemQuantity:(id) sender{
    UIButton *minus = (UIButton *) sender;
    UIButton *add = (UIButton *) [self.view viewWithTag:(minus.tag-1)];
    UILabel *label = (UILabel *) [self.view viewWithTag:(minus.tag-2)];
    label.text = [NSString stringWithFormat:@"%i",([label.text intValue]-1)];
    minus.enabled = ([label.text intValue] > 0);
    add.enabled = ([label.text intValue] < 100);
}


-(void) submitOrder:(id) sender {
    if ([PFUser currentUser]) {
        [self checkForTransaction];
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
    [bundleObject setObject:[NSDate dateWithTimeIntervalSinceNow:3600] forKey:@"delivryBy"];
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

- (void)checkForTransaction {
    PFQuery *query = [PFQuery queryWithClassName:@"CartItems"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects == nil || [objects count] == 0) {
                [self createTransaction:nil];
            }
            else {
                PFObject *transactionObject = [[objects objectAtIndex:0] objectForKey:@"transaction"];
                [self createOrder:transactionObject];
            }
            NSLog(@"Info (Parse): Successfully found transaction.");
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

-(void) createTransaction:(PFObject *)bundleObject {
    PFObject *transactionObject = [PFObject objectWithClassName:@"Transactions"];
    // [transactionObject setObject:bundleObject forKey:@"bundle"];
    [transactionObject setObject:[PFUser currentUser] forKey:@"user"];
    // [transactionObject setObject:[PFGeoPoint geoPointWithLocation:self.currentLocation] forKey:@"delivryLocation"];
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
    NSMutableArray *cartItems = [[NSMutableArray alloc] init];
    NSMutableArray *removeCartItems = [[NSMutableArray alloc] init];
    // Create a list of OrderItems
    for (int i = 0; i < self.restaurantItems.count; i++) {
        UILabel *quantityLabel = self.quantity[i];
        PFObject *restaurantItem = self.restaurantItems[i];
        PFObject *previousCartItem = nil;
        for (int j = 0; j < self.cartItems.count; j++) {
            PFObject *cartItem = [self.cartItems objectAtIndex:j];
            PFObject *cartRestaurantItem = [cartItem objectForKey:@"restaurantItem"];
            if ([cartRestaurantItem.objectId isEqual:restaurantItem.objectId]) {
                previousCartItem = cartItem;
            }
        }
        if (![quantityLabel.text isEqual: @"0"]) {
            NSNumber *quantity = [[NSNumber alloc] initWithInt:[quantityLabel.text intValue]];
            
            if (previousCartItem == nil) {
                PFObject *cartItem = [PFObject objectWithClassName:@"CartItems"];
                [cartItem setObject:transactionObject forKey:@"transaction"];
                [cartItem setObject:restaurantItem forKey:@"restaurantItem"];
                [cartItem setObject:quantity forKey:@"quantity"];
                [cartItems addObject:cartItem];
            }
            else {
                [previousCartItem setObject:quantity forKey:@"quantity"];
                [cartItems addObject:previousCartItem];
//                
//                PFObject *removeCartItem = [PFObject objectWithClassName:@"CartItems"];
//                [removeCartItem setObjectId:previousCartItem.objectId];
//                
//                [removeCartItems addObject:removeCartItem];
            }
        }
        else {
            if (previousCartItem == nil) {
                // do nothing
                NSLog(@"blah");
            }
            else {
                PFObject *removeCartItem = [PFObject objectWithClassName:@"CartItems"];
                [removeCartItem setObjectId:previousCartItem.objectId];
                
                [removeCartItems addObject:removeCartItem];
            }
        }
    }
    
    [PFObject deleteAllInBackground:removeCartItems block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Info (Parse): Cart Items have been successfully removed.");
            [PFObject saveAllInBackground:cartItems block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Info (Parse): Cart Items have been successfully saved.");
                }
                else {
                    NSLog(@"Error (Parse): %@",error);
                }
            }];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
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
