//
//  HomeViewController.h
//  Delivry
//
//  Created by Eddie Hou on 2014-11-28.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>

@interface HomeViewController : UIViewController <CLLocationManagerDelegate>



@property(nonatomic, strong) PFUser *user;
@property(nonatomic, strong) CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UITextView *nearbyRestaurantDisplay;

@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longtitudeLabel;
@property (strong, nonatomic) NSArray *nearbyRestaurants;

- (IBAction)updateLocation:(id)sender;


@end
