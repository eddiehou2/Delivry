//
//  CreateRestaurantViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-11-29.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "CreateRestaurantViewController.h"
#import "HomeViewController.h"

@interface CreateRestaurantViewController ()

@end

@implementation CreateRestaurantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CLLocationCoordinate2D restaurantCood = [self.restaurantLocation coordinate];
    self.latitudeLabel.text = [NSString stringWithFormat: @"%f",restaurantCood.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat: @"%f",restaurantCood.longitude];
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
        PFGeoPoint *restaurantPoint = [PFGeoPoint geoPointWithLocation:self.restaurantLocation];
        NSLog(@"name: %@ // description: %@ // location: %@",self.restaurantName.text,self.restaurantDescription.text,restaurantPoint);
        PFObject *newRestaurant = [PFObject objectWithClassName:@"Restaurants"];
        newRestaurant[@"restaurantName"] = self.restaurantName.text;
        newRestaurant[@"restaurantDescription"] = self.restaurantDescription.text;
        newRestaurant[@"restaurantLocation"] = restaurantPoint;
        [newRestaurant saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"createRestaurant failWithError: %@", error);
            }
            
            if (succeeded) {
                [self alertMessage:@"Successfully created a restaurant!" title:@"Successful:"];
            }
            else {
                [self alertMessage:@"An error occurred in the process of creating a restaurant. Please try again." title:@"Error:"];
            }
        }];
    }
}

- (IBAction)cancelled:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
        
- (void) alertMessage:(NSString *)message title:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:ok];
    
    //[self presentViewController:alertController animated:YES completion:nil];
}

        
@end
