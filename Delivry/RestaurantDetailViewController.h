//
//  RestaurantDetailViewController.h
//  Delivry
//
//  Created by Eddie Hou on 2014-12-27.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface RestaurantDetailViewController : UIViewController

@property(nonatomic, strong) NSMutableDictionary *restaurant;
@property(nonatomic, strong) CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *minimumLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;


@end
