//
//  delivryUser.m
//  Delivry
//
//  Created by Eddie Hou on 2014-12-29.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "DEUser.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@implementation DEUser

+(DEUser *) getInformationFromCurrentUser {
    DEUser *currentUser = (DEUser *)[DEUser currentUser];
    if (currentUser != nil) {
        
        DEUser *user = currentUser;
        if ([PFFacebookUtils isLinkedWithUser:currentUser]) {
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSDictionary *userData = (NSDictionary *)result;
                    
                    user.name = userData[@"name"];
                    user.email = userData[@"email"];
                    user.number = userData[@"number"];
                    user.friends = userData[@"friends"];
                }
                else {
                    NSLog(@"Error: DEUser/getInformationFromCurrentUser/startWithCompletionHandler");
                }
            }];
        }
        else {
            PFQuery *query =[PFQuery queryWithClassName:@"UserInformation"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    NSDictionary *results = objects[0];
                    user.name = results[@"name"];
                    user.email = results[@"email"];
                    user.number = results[@"number"];
                }
                else {
                    NSLog(@"Error: DEUser/getInformationFromCurrentUser/findObjectsInBackgroundWithBlock");
                }
            }];
        }
        return user;
    }
    else {
        return nil;
    }
}

@end
