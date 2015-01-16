//
//  FilterRestaurantViewController.h
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-10.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FilterRestaurantViewController : UIViewController

@property(nonatomic, strong) UISearchBar *searchBar;
@property(nonatomic, strong) UISearchBar *locationBar;
@property(nonatomic, strong) CLLocation *currentLocation;
@property (strong, nonatomic) IBOutlet UISegmentedControl *priceSegmentControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *distanceSegmentControl;
@property (strong, nonatomic) IBOutlet UISwitch *newlyOpenSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *popularSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *discountForLargeOrderSwitch;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sortBySegmentControl;


@property(nonatomic, assign) NSInteger priceIndex;
@property(nonatomic, assign) BOOL popular;
@property(nonatomic, assign) BOOL newlyOpen;
@property(nonatomic, assign) NSInteger distanceIndex;
@property(nonatomic, assign) BOOL discountForLargeOrder;
@property(nonatomic, assign) NSInteger sortByIndex;

@property(nonatomic, strong) NSString *keywordFilter;
@property(nonatomic, strong) NSString *addressFilter;

@end
