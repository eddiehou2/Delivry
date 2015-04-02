//
//  CartViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-13.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "CartViewController.h"
#import "CheckoutViewController.h"
#import <Parse/Parse.h>
#import "Stripe.h"
#import "LoadingView.h"
#import "DEGeocodingServices.h"

const int LABELHEIGHT = 30;
const int ITEMHEIGHT = 30;
const int SUBTOTALHEIGHT = 120;
const int QUANTITYWIDTH = 40;
const int PRICEWIDTH = 60;
const int SUBTOTALITEMHEIGHT = 20;

const int STATUSBARHEIGHT = 20;

@interface CartViewController () <UIGestureRecognizerDelegate>

@end

@implementation CartViewController{
    NSMutableArray *restaurantsArray;
    // Array -> Dictionary(restaurant.objectId,Array)
    int noRestaurants;
    int cellYPosition;
    float subtotal;
    int subtotalYPosition;
    
    int distance;
    int duration;
    float delivryFee;
    float totalPrice;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // [self retrievingAllParseRestaurantItems];
    // [self populateParseTokens];
    UIBarButtonItem *checkout = [[UIBarButtonItem alloc] initWithTitle:@"Checkout" style:UIBarButtonItemStyleDone target:self action:@selector(checkoutItems:)];
    self.navigationItem.rightBarButtonItem = checkout;
}

-(void)viewDidAppear:(BOOL)animated {
    self.view = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    subtotal = 0;
    distance = 0;
    duration = 0;
    delivryFee = 0;
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
            [PFObject fetchAllInBackground:self.cartItems block:^(NSArray *objects, NSError *error) {
                if (!error) {
                    NSMutableArray *restaurantItems = [[NSMutableArray alloc] init];
                    for (PFObject *object in self.cartItems) {
                        [restaurantItems addObject:[object objectForKey:@"restaurantItem"]];
                    }
                    [PFObject fetchAllInBackground:restaurantItems block:^(NSArray *restaurantItemsObjects, NSError *error) {
                        if (!error) {
                            NSLog(@"Info (Parse): Successfully fetched restaurant items.");
                            NSMutableArray *restaurants = [[NSMutableArray alloc] init];
                            for (PFObject *restaurantItemsObject in restaurantItems) {
                                [restaurants addObject:[restaurantItemsObject objectForKey:@"restaurant"]];
                            }
                            [PFObject fetchAllInBackground:restaurants block:^(NSArray *restaurantsObjects, NSError *error) {
                                if (!error) {
                                    NSLog(@"Info (Parse): Successfully fetched restaurants.");
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
                                    NSLog(@"999");
                                    [self calculateDelivryFee];
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
            }];
            

        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

- (void)reloadCartView {
    NSLog(@"AAA");
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor = [UIColor whiteColor];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, STATUSBARHEIGHT+self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-(STATUSBARHEIGHT+self.navigationController.navigationBar.frame.size.height+self.tabBarController.tabBar.frame.size.height))];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, noRestaurants*LABELHEIGHT+self.cartItems.count*ITEMHEIGHT+SUBTOTALHEIGHT);
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    if (self.cartItems.count != 0 && self.cartItems) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.restaurantName = [[[self.cartItems objectAtIndex:0] objectForKey:@"restaurantItem"] objectForKey:@"restaurant"];
        self.transactionObject = [[self.cartItems objectAtIndex:0] objectForKey:@"transaction"];
        self.yPosition = 0;
        self.restaurantItems = [[NSMutableArray alloc] init];
    
        for (NSDictionary *dictionary in restaurantsArray) {
            [self createRestaurantNameLabel:[dictionary objectForKey:@"restaurantName"]];
            [self createItemsChildTableView:[dictionary objectForKey:@"array"]];
        }
        [self createSubtotalSection];
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        label.text = @"Uh oh! No items has been added to the cart!";
        label.textColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:label];
    }
    NSLog(@"BBB");
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
    //[self calculateDelivryFee];
    [self createSubtotalItemWithName:@"Delivry Fee" amount:delivryFee view:view];
    double driverTip = subtotal*0.15;
    [self createSubtotalItemWithName:@"Driver Tip" amount:driverTip view:view];
    double discount = 0.00;
    [self createSubtotalItemWithName:@"Discount" amount:discount view:view];
    totalPrice = subtotal + tax + delivryFee + driverTip - discount;
    [self createSubtotalItemWithName:@"Total" amount:totalPrice view:view];
    
    [self.scrollView addSubview:view];
    self.subtotalView = view;
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
    NSLog(@"%@", cartItem);
    quantityLabel.text = [NSString stringWithFormat:@"%@x",[cartItem objectForKey:@"quantity"]];
    [view addSubview:quantityLabel];
    
    PFObject *restaurantItem = [cartItem objectForKey:@"restaurantItem"];
    UILabel *itemNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(QUANTITYWIDTH, cellYPosition, self.view.frame.size.width-90, ITEMHEIGHT)];
    itemNameLabel.text = [restaurantItem objectForKey:@"itemName"];
    [view addSubview:itemNameLabel];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(decreaseAllQuantity:)];
    leftSwipe.delegate = self;
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [itemNameLabel addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(decreaseQuantity:)];
    rightSwipe.delegate = self;
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [itemNameLabel addGestureRecognizer:rightSwipe];
    
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

- (void)checkoutItems:(id)sender {
    CheckoutViewController *checkoutViewController = [[CheckoutViewController alloc] init];
    checkoutViewController.totalPrice = totalPrice;
    checkoutViewController.subtotalView = self.subtotalView;
    checkoutViewController.transactionObject = self.transactionObject;
    [self.navigationController pushViewController:checkoutViewController animated:YES];
}

- (void)decreaseAllQuantity:(id)sender {
    NSLog(@"decrease all quantity w/ %@",sender);
}

- (void)decreaseQuantity:(id)sender {
    NSLog(@"decrease one quantity w/ %@",sender);
}

- (void)calculateDelivryFee {
    NSString *defaultAddress = @"37 Grosvenor St., Toronto, ON";
    
    NSLog(@"888");
    NSMutableArray *objectIdArray = [[NSMutableArray alloc] init];
    NSLog(@"count: %lu", (unsigned long)restaurantsArray.count);
    for (NSDictionary *dictionary in restaurantsArray) {
        NSLog(@"%@",[dictionary objectForKey:@"objectId"]);
        PFObject *objectWithId = [[PFObject alloc] initWithClassName:@"Restaurants"];
        NSLog(@"huh?");
        objectWithId.objectId = [dictionary objectForKey:@"objectId"];
        [objectIdArray addObject:objectWithId];
        NSLog(@"not working?");
    }
    NSLog(@"777");
    [PFObject fetchAllIfNeededInBackground:objectIdArray block:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Info (Parse): Successfully fetched restaurant infos.");
            for (PFObject *object in objects) {
                NSDictionary *pathingInfo = [DEGeocodingServices findPathingBetween:defaultAddress to: [object objectForKey:@"restaurantAddress"]];
                distance += [[pathingInfo objectForKey:@"distance"] intValue];
                duration += [[pathingInfo objectForKey:@"duration"] intValue];
            }
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
    
    [self reloadCartView];
}

- (void)calculateDelivryFeeWithTotalDistance {
    PFQuery *delivryFeeQuery = [PFQuery queryWithClassName:@"DelivryFees"];
    [delivryFeeQuery whereKey:@"ValidTo" greaterThanOrEqualTo:[NSDate date]];
    [delivryFeeQuery whereKey:@"ValidFrom" lessThanOrEqualTo:[NSDate date]];
    [delivryFeeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Info (Parse): Successfully get delivry fee rates.");
            PFObject *object = [objects objectAtIndex:0];
            double distanceFee = [self calculateDistanceBasedFeeWithGasFirst:[[object objectForKey:@"GasFirst"] floatValue] kmFirst:[[object objectForKey:@"KmFirst"] floatValue] gasAfter:[[object objectForKey:@"GasAfter"] floatValue]];
            double timeFee = [self calculateTimeBasedFeeWithTimeFirst:[[object objectForKey:@"TimeFirst"] floatValue] amountTimeFirst:[[object objectForKey:@"AmountTimeFirst"] floatValue] timeAfter:[[object objectForKey:@"TimeAfter"] floatValue]];
            double restaurantFee = [[object objectForKey:@"RestaurantFirst"] floatValue] + [[object objectForKey:@"RestaurantAfter"] floatValue]*restaurantsArray.count;
            delivryFee = distanceFee + timeFee + restaurantFee;
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

- (double)calculateDistanceBasedFeeWithGasFirst:(float)gasFirst kmFirst:(float)kmFirst gasAfter:(float)gasAfter {
    float distanceInKm = distance/1000;
    if (distanceInKm <= kmFirst) {
        return distanceInKm*gasAfter;
    }
    else {
        return (distanceInKm-kmFirst)*gasAfter + kmFirst*gasFirst;
    }
}

- (double)calculateTimeBasedFeeWithTimeFirst:(float)timeFirst amountTimeFirst:(float)amountTimeFirst timeAfter:(float)timeAfter {
    float durationInMin = duration/60;
    if (durationInMin <= amountTimeFirst) {
        return durationInMin*timeFirst;
    }
    else {
        return (durationInMin-amountTimeFirst)*timeFirst + amountTimeFirst*timeAfter;
    }
}

#pragma mark Parse Scripts

- (void)retrievingAllParseRestaurantItems {
    PFQuery *query = [PFQuery queryWithClassName:@"RestaurantItems"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Info (Parse): Successfully retrieve all restaurant items.");
            [self createTransactionForObjects:objects];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

- (void)populateParseCartItems:(NSArray *)objects transaction:(PFObject *)transaction {
    NSMutableArray *cartItems = [[NSMutableArray alloc] init];
    for (PFObject *object in objects) {
        PFObject *cartItem = [PFObject objectWithClassName:@"CartItems"];
        [cartItem setObject:object forKey:@"restaurantItem"];
        [cartItem setObject:@1 forKey:@"quantity"];
        [cartItem setObject:transaction forKey:@"transaction"];
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

-(void) createTransactionForObjects:(NSArray *)objects {
    PFObject *transactionObject = [PFObject objectWithClassName:@"Transactions"];
    [transactionObject setObject:[PFUser currentUser] forKey:@"user"];
    [transactionObject setObject:@"Address goes here" forKey:@"delivryAddress"];
    [transactionObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self populateParseCartItems:objects transaction:transactionObject];
            NSLog(@"Info (Parse): Transaction Object has been successfully created.");
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

- (void)populateParseTokens {
    STPCard *card = [[STPCard alloc] init];
    
    card.number = @"4242424242424242";
    card.expMonth = 5;
    card.expYear = 2015;
    card.cvc = @"969";
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (!error) {
            NSLog(@"Token: %@",token);
            [PFCloud callFunctionInBackground:@"createCustomer" withParameters:@{@"token":token.tokenId,@"user":[PFUser currentUser].objectId} block:^(id object, NSError *error) {
                if (!error) {
                    NSLog(@"NICE!");
                }
                else {
                    NSLog(@"FUCK! Error: %@", error);
                }
            }];
//            PFObject *tokenObject = [PFObject objectWithClassName:@"Tokens"];
//            [tokenObject setObject:token.tokenId forKey:@"token"];
//            [tokenObject setObject:[PFUser currentUser] forKey:@"user"];
//            [tokenObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                if (succeeded) {
//                    NSLog(@"Info (Parse): Successfully saved token.");
//                }
//                else {
//                    NSLog(@"Error (Parse): %@",error);
//                }
//            }];
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
