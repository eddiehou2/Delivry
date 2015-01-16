//
//  CartViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-13.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "CartViewController.h"
#import <Parse/Parse.h>

const int LABELHEIGHT = 30;
const int ITEMHEIGHT = 30;
const int SUBTOTALHEIGHT = 120;
const int QUANTITYWIDTH = 40;
const int PRICEWIDTH = 60;
const int SUBTOTALITEMHEIGHT = 20;

const int STATUSBARHEIGHT = 20;

@interface CartViewController ()

@end

@implementation CartViewController{
    NSMutableArray *restaurantsArray;
    // Array -> Dictionary(restaurant.objectId,Array)
    int noRestaurants;
    int cellYPosition;
    float subtotal;
    int subtotalYPosition;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self retrievingAllParseRestaurantItems];
}

-(void)viewDidAppear:(BOOL)animated {
    [self retrieveCartItems];
}

- (void)retrieveCartItems {
    PFQuery *cartItemQuery = [PFQuery queryWithClassName:@"CartItems"];
    [cartItemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Info (Parse): Successfully retrieved cart items.");
            self.cartItems = [objects mutableCopy];
            noRestaurants = 0;
            restaurantsArray = [[NSMutableArray alloc] init];
            [PFObject fetchAll:self.cartItems];
            NSMutableArray *restaurantItems = [[NSMutableArray alloc] init];
            for (PFObject *object in self.cartItems) {
                [restaurantItems addObject:[object objectForKey:@"restaurantItem"]];
            }
            [PFObject fetchAll:restaurantItems];
            NSMutableArray *restaurants = [[NSMutableArray alloc] init];
            for (PFObject *object in restaurantItems) {
                [restaurants addObject:[object objectForKey:@"restaurant"]];
            }
            [PFObject fetchAll:restaurants];
            for (PFObject *object in objects) {
                BOOL included = NO;
                PFObject *restaurant = [[object objectForKey:@"restaurantItem"] objectForKey:@"restaurant"];
                for (NSDictionary *dictionary in restaurantsArray) {
                    if ([[dictionary objectForKey:@"objectId"] isEqualToString:restaurant.objectId]) {
                        NSMutableArray *array = [dictionary objectForKey:@"array"];
                        [array addObject:object];
                        included = YES;
                    }
                }
                if (!included) {
                    NSDictionary *dictionary = @{@"objectId":restaurant.objectId,@"array":[[NSMutableArray alloc] initWithObjects:object, nil],@"restaurantName":[restaurant objectForKey:@"restaurantName"]};
                    [restaurantsArray addObject:dictionary];
                    noRestaurants += 1;
                }
            }
            NSLog(@"Number: %i",noRestaurants);
            NSLog(@"Array: %@",restaurantsArray);
            [self reloadCartView];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

- (void)reloadCartView {
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor = [UIColor whiteColor];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, STATUSBARHEIGHT, self.view.frame.size.width, self.view.frame.size.height-STATUSBARHEIGHT)];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, noRestaurants*LABELHEIGHT+self.cartItems.count*ITEMHEIGHT+SUBTOTALHEIGHT);
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    
    self.restaurantName = [[[self.cartItems objectAtIndex:0] objectForKey:@"restaurantItem"] objectForKey:@"restaurant"];
    self.yPosition = 0;
    self.restaurantItems = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dictionary in restaurantsArray) {
        [self createRestaurantNameLabel:[dictionary objectForKey:@"restaurantName"]];
        [self createItemsChildTableView:[dictionary objectForKey:@"array"]];
    }
    [self createSubtotalSection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createRestaurantNameLabel:(NSString *)restaurantName {
    UILabel *restaurantNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.yPosition, self.view.frame.size.width, LABELHEIGHT)];
    restaurantNameLabel.text = restaurantName;
    restaurantNameLabel.font = [UIFont systemFontOfSize:18];
    restaurantNameLabel.backgroundColor = [UIColor lightGrayColor];
    restaurantNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:restaurantNameLabel];
    self.yPosition += restaurantNameLabel.frame.size.height;
    
    [self createSectionSeperatorView];
}

- (void)createItemsChildTableView:(NSMutableArray *)items {
    [self createListForItems:items];
    [self createSectionSeperatorView];
}

- (void)createSectionSeperatorView {
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, self.yPosition-1, self.view.frame.size.width, 2)];
    seperator.backgroundColor = [UIColor blackColor];
    [self.scrollView addSubview:seperator];
}

- (void)createItemSeperatorView {
    UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, self.yPosition, self.view.frame.size.width, 1)];
    seperator.backgroundColor = [UIColor lightGrayColor];
    [self.scrollView addSubview:seperator];
}

- (void)createSubtotalSection {
    subtotalYPosition = 0;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.yPosition, self.view.frame.size.width, SUBTOTALHEIGHT)];
    
    [self createSubtotalItemWithName:@"Subtotal" amount:subtotal view:view];
    double tax = subtotal*0.13;
    [self createSubtotalItemWithName:@"Tax" amount:tax view:view];
    double delivryFee = 4.99;
    [self createSubtotalItemWithName:@"Delivry Fee" amount:delivryFee view:view];
    double driverTip = subtotal*0.15;
    [self createSubtotalItemWithName:@"Driver Tip" amount:driverTip view:view];
    double discount = 0.00;
    [self createSubtotalItemWithName:@"Discount" amount:discount view:view];
    double total = subtotal + tax + delivryFee + driverTip - discount;
    [self createSubtotalItemWithName:@"Total" amount:total view:view];
    
    [self.scrollView addSubview:view];
    [self createSectionSeperatorView];
}

- (void)createSubtotalItemWithName:(NSString *)name amount:(double)amount view:(UIView *)view{
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, subtotalYPosition, 100, SUBTOTALITEMHEIGHT)];
    nameLabel.text = name;
    [view addSubview:nameLabel];
    
    UILabel *amountLabel = [self createPriceLabel:CGRectMake(view.frame.size.width-PRICEWIDTH, subtotalYPosition, PRICEWIDTH, SUBTOTALITEMHEIGHT)];
    amountLabel.text = [NSString stringWithFormat:@"$%.2f",amount];
    [view addSubview:amountLabel];
    subtotalYPosition += SUBTOTALITEMHEIGHT;
    self.yPosition += SUBTOTALITEMHEIGHT;
}

- (void)createListForItems:(NSArray *)cartItems {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.yPosition, self.view.frame.size.width, cartItems.count*ITEMHEIGHT)];
    cellYPosition = 0;
    for (PFObject *object in cartItems) {
        [self createCellForItem:object forView:view];
        self.yPosition += ITEMHEIGHT;
        [self createItemSeperatorView];
    }
    [self.scrollView addSubview:view];
    
}

- (void)createCellForItem:(PFObject *)cartItem forView:(UIView *)view{
    UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, cellYPosition, QUANTITYWIDTH, ITEMHEIGHT)];
    quantityLabel.text = [NSString stringWithFormat:@"%@x",[cartItem objectForKey:@"quantity"]];
    [view addSubview:quantityLabel];
    
    PFObject *restaurantItem = [cartItem objectForKey:@"restaurantItem"];
    UILabel *itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(QUANTITYWIDTH, cellYPosition, self.view.frame.size.width-90, ITEMHEIGHT)];
    itemNameLabel.text = [restaurantItem objectForKey:@"itemName"];
    [view addSubview:itemNameLabel];
    
    double itemSubtotal = [[restaurantItem objectForKey:@"itemPrice"] floatValue]*[[cartItem objectForKey:@"quantity"] intValue];
    subtotal += itemSubtotal;
    UILabel *subtotalPriceLabel = [self createPriceLabel:CGRectMake(self.view.frame.size.width-PRICEWIDTH, cellYPosition, PRICEWIDTH, ITEMHEIGHT)];
    subtotalPriceLabel.text = [NSString stringWithFormat:@"$%.2f",itemSubtotal];
    [view addSubview:subtotalPriceLabel];
    cellYPosition += ITEMHEIGHT;
}

- (UILabel *)createPriceLabel:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentRight;
    return label;
}

#pragma mark Parse Scripts

- (void)retrievingAllParseRestaurantItems {
    PFQuery *query = [PFQuery queryWithClassName:@"RestaurantItems"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Info (Parse): Successfully retrieve all restaurant items.");
            [self populateParseCartItems:objects];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

- (void)populateParseCartItems:(NSArray *)objects {
    NSMutableArray *cartItems = [[NSMutableArray alloc] init];
    for (PFObject *object in objects) {
        PFObject *cartItem = [PFObject objectWithClassName:@"CartItems"];
        [cartItem setObject:object forKey:@"restaurantItem"];
        [cartItem setObject:@1 forKey:@"quantity"];
        [cartItems addObject:cartItem];
    }
    
    [PFObject saveAllInBackground:cartItems block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Info (Parse): Successfully populated cart items.");
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
