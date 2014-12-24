//
//  HomeViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-11-28.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "HomeViewController.h"
#import "CreateRestaurantViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController {
    CLLocationManager *locationManager;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    locationManager = [[CLLocationManager alloc] init];
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
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
    
    // Retrieving Nearby Restaurants
    [self retrieveNearbyRestaurantsWithGeoPoint:currentLocation withinKilometers:10.0];
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"createRestaurant"]) {
        NSLog(@"HERE");
        CreateRestaurantViewController *createRestaurantViewController = [segue destinationViewController];
        NSLog(@"%@",self.currentLocation);
        
        createRestaurantViewController.restaurantLocation = self.currentLocation;
    }
}
@end
