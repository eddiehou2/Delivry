//
//  delivryUser.h
//  Delivry
//
//  Created by Eddie Hou on 2014-12-29.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <Parse/Parse.h>

@interface DEUser : PFUser

@property(nonatomic, weak) NSString *name;
@property(nonatomic, weak) NSString *title;
@property(nonatomic, weak) NSString *number;
@property(nonatomic, weak) UIImage *image;
@property(nonatomic, weak) NSArray *friends;
@property(nonatomic, weak) NSString *payment;
@property(nonatomic, weak) NSArray *address;

+(DEUser *) getInformationFromCurrentUser;

@end
