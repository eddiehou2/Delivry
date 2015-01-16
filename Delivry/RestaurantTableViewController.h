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

@property(nonatomic, assign) NSInteger priceIndex;
@property(nonatomic, assign) BOOL popular;
@property(nonatomic, assign) BOOL newlyOpen;
@property(nonatomic, assign) double distance;
@property(nonatomic, assign) NSInteger distanceIndex;
@property(nonatomic, assign) BOOL discountForLargeOrder;
@property(nonatomic, strong) NSString *sortBy;
@property(nonatomic, assign) NSInteger sortByIndex;

@property(nonatomic, strong) NSString *keywordFilter;
@property(nonatomic, strong) NSString *addressFilter;

- (void)savingFilteringsForPriceIndex:(NSInteger)priceIndex popular:(BOOL)popular newlyOpen:(BOOL)newlyOpen distance:(double)distance distanceIndex:(NSInteger)distanceIndex discountForLargeOrder:(BOOL)discountForLargeOrder sortBy:(NSString *)sortBy sortByIndex:(NSInteger)sortByIndex keywordFilter:(NSString *)keywordFilter addressFilter:(NSString *)addressFilter;

@end
