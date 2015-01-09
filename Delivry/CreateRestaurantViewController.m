//
//  CreateRestaurantViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-11-29.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "CreateRestaurantViewController.h"
#import "HomeViewController.h"
#import "DEGeocodingServices.h"
#import <GoogleMaps/GoogleMaps.h>

@interface CreateRestaurantViewController () <UITextFieldDelegate>

@end

@implementation CreateRestaurantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CLLocationCoordinate2D restaurantCood = [self.restaurantLocation coordinate];
    self.latitudeLabel.text = [NSString stringWithFormat: @"%f",restaurantCood.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat: @"%f",restaurantCood.longitude];
    
    [self.locationOrAddressSwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)createRestaurant:(id)sender {
    if ([self.restaurantName.text length] == 0) {
        [self alertMessage:@"Restaurant must have a name! Please try again." title:@"Error"];
    }
    else if ([self.restaurantDescription.text length] == 0) {
        [self alertMessage:@"Restaurant must have a description! Please try again." title:@"Error"];
    }
    else {
        if (self.locationOrAddressSwitch.isOn) {
            DEGeocodingServices *geocoder = [[DEGeocodingServices alloc] init];
            [geocoder geocodeAddress:self.restaurantAddress.text];
            self.restaurantLocation = [[CLLocation alloc] initWithLatitude:[[geocoder.geocode objectForKey:@"lat"] floatValue] longitude:[[geocoder.geocode objectForKey:@"lng"] floatValue]];
            [self saveRestaurant];
        }
        else {
            [[GMSGeocoder geocoder] reverseGeocodeCoordinate:self.restaurantLocation.coordinate completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
                if (!error) {
                    GMSAddress *address = [[response results] objectAtIndex:0];
                    self.restaurantAddress.text = [NSString stringWithFormat:@"%@, %@",[address thoroughfare],[address locality]];
                    [self saveRestaurant];
                }
                else {
                    NSLog(@"Error (GMS): %@",error);
                }
            }];
        }
        
    }
}

- (IBAction)cancelled:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
        
- (void) alertMessage:(NSString *)message title:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setState:(id) sender {
    BOOL state = [sender isOn];
    if (state) {
        self.longitudeLabel.textColor = [UIColor grayColor];
        self.latitudeLabel.textColor = [UIColor grayColor];
        self.restaurantAddress.enabled = YES;
    }
    else {
        self.latitudeLabel.textColor = [UIColor blackColor];
        self.longitudeLabel.textColor = [UIColor blackColor];
        self.restaurantAddress.enabled = NO;
    }
}

- (void)saveRestaurant {
    PFGeoPoint *restaurantPoint = [PFGeoPoint geoPointWithLocation:self.restaurantLocation];
    NSLog(@"name: %@ // description: %@ // location: %@",self.restaurantName.text,self.restaurantDescription.text,restaurantPoint);
    PFObject *newRestaurant = [PFObject objectWithClassName:@"Restaurants"];
    newRestaurant[@"restaurantName"] = self.restaurantName.text;
    newRestaurant[@"restaurantDescription"] = self.restaurantDescription.text;
    newRestaurant[@"restaurantLocation"] = restaurantPoint;
    newRestaurant[@"restaurantAddress"] = self.restaurantAddress.text;
    newRestaurant[@"restaurantPrice"] = @1;
    newRestaurant[@"restaurantMinimum"] = @20;
    [newRestaurant saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self alertMessage:@"Successfully created a restaurant!" title:@"Successful:"];
        }
        else {
            [self alertMessage:@"An error occurred in the process of creating a restaurant. Please try again." title:@"Error:"];
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}


@end
