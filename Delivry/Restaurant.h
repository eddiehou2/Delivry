//
//  Restaurant.h
//  Delivry
//
//  Created by Eddie Hou on 2014-11-28.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Restaurant : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSArray *tags;
@property(nonatomic, strong) NSString *summary;
@property(nonatomic, strong) NSString *address;
@property(nonatomic) float waitTime;
@property(nonatomic) float averagePrice;
@property(nonatomic, strong) PFGeoPoint *location;

@end
