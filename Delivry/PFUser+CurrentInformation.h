//
//  PFUser+CurrentInformation.h
//  Delivry
//
//  Created by Eddie Hou on 2014-12-30.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFUser (CurrentInformation)

@property(nonatomic, weak) NSString *name;
@property(nonatomic, weak) NSString *title;
@property(nonatomic, weak) NSString *number;
@property(nonatomic, weak) UIImage *image;
@property(nonatomic, weak) NSMutableArray *friends;
@property(nonatomic, weak) NSString *payment;
@property(nonatomic, weak) NSString *homeAddress;
@property(nonatomic, weak) PFGeoPoint *homeLocation;

+(PFUser *) getInformationFromCurrentUser;

@end
