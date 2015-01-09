//
//  HomeViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-11-28.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "HomeViewController.h"
#import "CreateRestaurantViewController.h"
#import "RestaurantTableViewController.h"
#import "Stripe.h"
#import "DEGeocodingServices.h"
#import <FacebookSDK/FacebookSDK.h>

#define NEARBY_DISTANCE 5.0

@interface HomeViewController ()

@end

@implementation HomeViewController {
    CLLocationManager *locationManager;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    locationManager = [[CLLocationManager alloc] init];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayRestaurantList)];
    tapRecognizer.numberOfTapsRequired = 2;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.nearbyRestaurantDisplay addGestureRecognizer:tapRecognizer];
    
    //[self parseScripts];
    
    [PFUser logOut];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateLocation:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateLocation:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    NSLog(@"Start Updating Location");
    
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    
    NSLog(@"Stop Updating Location");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"locationManager didFailWithError: %@", error);
    [self alertMessage:@"Failed to get your location! Please turn on location for this App." title:@"Error:"];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations objectAtIndex:[locations count]-1];
    NSLog(@"locationManager didUpdateToLocation: %@",currentLocation);
    
    if (currentLocation != nil) {
        self.currentLocation = currentLocation;
        self.longtitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.longtitudeLabel.text forKey:@"currentLongitude"];
        [defaults setObject:self.latitudeLabel.text forKey:@"currentLatitude"];
        [defaults synchronize];
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
    
    // Retrieving Nearby Restaurants
    [self retrieveNearbyRestaurantsWithGeoPoint:currentLocation withinKilometers:5.0f];
}

- (void) alertMessage:(NSString *)message title:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) retrieveNearbyRestaurantsWithGeoPoint:(CLLocation *)currentLocation withinKilometers:(double)kilometers {
    PFGeoPoint *currentPont = [PFGeoPoint geoPointWithLocation:currentLocation];
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurants"];
    
    [query whereKey:@"restaurantLocation" nearGeoPoint:currentPont withinKilometers:kilometers];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"retrieveNearbyRestaurantsWithGeoPoint failWithError: %@", error);
            return;
        }
        
        self.nearbyRestaurants = objects;
        [self populateNearbyRestaurantDisplay];
    }];
}

- (void) populateNearbyRestaurantDisplay {
    self.nearbyRestaurantDisplay.text = @"Restaurant Listing:";
    for (PFObject *nearbyRestaurant in self.nearbyRestaurants) {
        self.nearbyRestaurantDisplay.text = [NSString stringWithFormat:@"%@\n%@\n",self.nearbyRestaurantDisplay.text,nearbyRestaurant];
    }
    NSLog(@"populateNearbyRestaurantDisplay Success! count: %lu",(unsigned long)[self.nearbyRestaurants count]);
}

-(void) displayRestaurantList {
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RestaurantTableViewController *rtvc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"restaurantTableViewController"];
    rtvc.currentLocation = self.currentLocation;
    rtvc.restaurants = self.nearbyRestaurants;
    
    [self.navigationController pushViewController:rtvc animated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"createRestaurant"]) {
        CreateRestaurantViewController *createRestaurantViewController = [segue destinationViewController];
        
        createRestaurantViewController.restaurantLocation = self.currentLocation;
    }
}

#pragma mark Parse Scripts

-(void)parseScripts {
    NSDate *now = [NSDate date];
    [self parseDeleteRestaurants:now];
    [self parseDeleteRestaurantItems:now];
}

-(void)parseDeleteRestaurants:(NSDate *)now {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurants"];
    [query whereKey:@"createdAt" lessThan:now];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [PFObject deleteAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Info (Parse): Restaurants before %@ have been successfully deleted.",now);
                    [self parsePopulateRestaurants];
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

-(void)parsePopulateRestaurants {
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    NSArray *restaurantNames = @[@"Tim Hortons",@"Subways",@"McDonald's",@"Booster Juice"];
    NSArray *restaurantDescriptions = @[@"Cheap Canadian Coffee",@"Eat Fresh",@"I'm Lovin' It",@"Drink It Up!"];
    NSArray *restaurantAddresses = @[@"76 Grenville St., Toronto, ON",@"200 Elizabeth St., Toronto, ON",@"356 Yonge St., Toronto, ON", @"257 College St., Toronto, ON"];
    NSMutableArray *restaurantLocations = [[NSMutableArray alloc] init];
    
    for (NSString *restaurantAddress in restaurantAddresses) {
        DEGeocodingServices *geocoder = [[DEGeocodingServices alloc] init];
        [geocoder geocodeAddress:restaurantAddress];
        [restaurantLocations addObject:geocoder.geocode];
    }
    
    for (int i = 0; i<restaurantNames.count ; i++) {
        PFObject *restaurant = [PFObject objectWithClassName:@"Restaurants"];
        [restaurant setObject:restaurantNames[i] forKey:@"restaurantName"];
        [restaurant setObject:[PFGeoPoint geoPointWithLatitude:[[restaurantLocations[i] objectForKey:@"lat"] floatValue] longitude:[[restaurantLocations[i] objectForKey:@"lng"] floatValue]] forKey:@"restaurantLocation"];
        [restaurant setObject:restaurantAddresses[i] forKey:@"restaurantAddress"];
        [restaurant setObject:restaurantDescriptions[i] forKey:@"restaurantDescription"];
        [restaurant setObject:@2 forKey:@"restaurantPrice"];
        [restaurant setObject:@20 forKey:@"restaurantMinimum"];
        
        [objects addObject:restaurant];
    }
    [PFObject saveAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Info (Parse): Restaurants have been successfully saved.");
            [self parsePopulateRestaurantItems];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

-(void)parseDeleteRestaurantItems:(NSDate *)now {
    PFQuery *deleteQuery = [PFQuery queryWithClassName:@"RestaurantItems"];
    [deleteQuery whereKey:@"createdAt" lessThan:now];
    [deleteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [PFObject deleteAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Info (Parse): Restaurant Items before %@ have been successfully deleted.",now);
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

-(void)parsePopulateRestaurantItems {
    NSMutableArray *saveObjects = [[NSMutableArray alloc] init];
    NSDictionary *restaurantItems = @{@"Tim Hortons":@[@{@"itemName":@"Iced Capp",@"itemPrice":@3.23,@"itemDescription":@"An Ice Beverage"},@{@"itemName":@"Hot Chocolate",@"itemPrice":@2.05,@"itemDescription":@"A Hot Beverage"},@{@"itemName":@"Extreme Italian",@"itemPrice":@4.99,@"itemDescription":@"A classic Sandwich"}],@"Subways":@[@{@"itemName":@"Cold Cut Combo",@"itemPrice":@3.29,@"itemDescription":@"6 inch"},@{@"itemName":@"Subway Club",@"itemPrice":@8.79,@"itemDescription":@"Foot long"},@{@"itemName":@"Chicken Pizziola",@"itemPrice":@5.99,@"itemDescription":@"6 inch"}],@"McDonald's":@[@{@"itemName":@"Big Mac",@"itemPrice":@6.79,@"itemDescription":@"A big burger"},@{@"itemName":@"Angus Deluxe",@"itemPrice":@6.89,@"itemDescription":@"a bigger burger"},@{@"itemName":@"Double Quarter Pounder",@"itemPrice":@7.39,@"itemDescription":@"a biggerr burger"}],@"Booster Juice":@[@{@"itemName":@"Power Smoothies",@"itemPrice":@5.65,@"itemDescription":@"Gives you energy!"},@{@"itemName":@"Tropical Smoothies",@"itemPrice":@5.35,@"itemDescription":@"Tropical Fruit Flavours"},@{@"itemName":@"High Protein Superfood Smoothies",@"itemPrice":@6.25,@"itemDescription":@"Workout in a drink!"}]};
    
    PFQuery *restaurantQuery = [PFQuery queryWithClassName:@"Restaurants"];
    [restaurantQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *restaurant in objects) {
            for (NSDictionary *restaurantItem in [restaurantItems objectForKey:[restaurant objectForKey:@"restaurantName"]]) {
                PFObject *item = [PFObject objectWithClassName:@"RestaurantItems"];
                [item setObject:restaurant forKey:@"restaurant"];
                [item setObject:[restaurantItem objectForKey:@"itemName"] forKey:@"itemName"];
                [item setObject:[restaurantItem objectForKey:@"itemPrice"] forKey:@"itemPrice"];
                [item setObject:[restaurantItem objectForKey:@"itemDescription"] forKey:@"itemDescription"];
                [saveObjects addObject:item];
            }
        }
        [PFObject saveAllInBackground:saveObjects block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Info (Parse): Restaurant Items have been successfully saved.");
                [self retrieveNearbyRestaurantsWithGeoPoint:self.currentLocation withinKilometers:NEARBY_DISTANCE];
                [self displayRestaurantList];
            }
            else {
                NSLog(@"Error (Parse): %@", error);
            }
        }];
    }];
}
@end
