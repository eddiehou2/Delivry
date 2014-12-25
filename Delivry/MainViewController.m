//
//  ViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-11-24.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurants"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query orderByDescending:@"restaurantName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (query.cachePolicy != kPFCachePolicyCacheOnly && error.code == kPFErrorCacheMiss) {
            return;
        }
        NSLog(@"%@",objects);
        
    }];
//    PFUser *user = [PFUser logInWithUsername:@"eddiehou2" password:@"12345"];
//    if (user.isAuthenticated) {
//        NSLog(@"Legit");
//    }
//    else {
//        NSLog(@"GTFO");
//    }
    
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile",@"email",@"user_friends"]];
    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width/2)), (self.view.frame.size.height - (loginView.frame.size.height + 5)));
    [self.view addSubview:loginView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
