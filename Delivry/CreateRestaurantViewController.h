//
//  CreateRestaurantViewController.h
//  Delivry
//
//  Created by Eddie Hou on 2014-11-29.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
@class HomeViewController;

@interface CreateRestaurantViewController : UIViewController

@property(nonatomic,strong) CLLocation *restaurantLocation;
@property(nonatomic,strong) HomeViewController *homeViewController;

@property (weak, nonatomic) IBOutlet UITextField *restaurantName;
@property (weak, nonatomic) IBOutlet UITextField *restaurantDescription;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;


- (IBAction)createRestaurant:(id)sender;
- (IBAction)cancelled:(id)sender;

@end
