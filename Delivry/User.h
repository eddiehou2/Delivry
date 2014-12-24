//
//  User.h
//  Delivry
//
//  Created by Eddie Hou on 2014-11-28.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *fname;
@property(nonatomic, strong) NSString *lname;
@property(nonatomic, strong) NSData *imageData;

//+ (void) userWithUser:

@end
