//
//  RestaurantTableViewController.h
//  Delivry
//
//  Created by Shuo-Min Amy Fan on 2014-12-24.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RestaurantTableViewController : UITableViewController

@property(nonatomic, strong) NSArray *restaurants;
@property(nonatomic, strong) CLLocation *currentLocation;

@end
