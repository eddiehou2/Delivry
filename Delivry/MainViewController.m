//
//  ViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-11-24.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "MainViewController.h"
#import "HomeViewController.h"
#import "AboutMeViewController.h"
#import "LogInViewController.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface MainViewController () <FBLoginViewDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
    
//    PFQuery *query = [PFQuery queryWithClassName:@"Restaurants"];
//    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//    [query orderByDescending:@"restaurantName"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//        if (query.cachePolicy != kPFCachePolicyCacheOnly && error.code == kPFErrorCacheMiss) {
//            return;
//        }
//        NSLog(@"%@",objects);
//    
//    }];
//    PFUser *user = [PFUser logInWithUsername:@"eddiehou2" password:@"12345"];
//    if (user.isAuthenticated) {
//        NSLog(@"Legit");
//    }
//    else {
//        NSLog(@"GTFO");
//    }
    
//    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile",@"email",@"user_friends"]];
//    loginView.delegate = self;
//    loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width/2)), (self.view.frame.size.height - (loginView.frame.size.height + 5)));
//    [self.view addSubview:loginView];
//    
//    if ([[FBSession activeSession] isOpen]) {
//        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
//            if (!error) {
//                [self handleFacebookLogin:user];
//            }
//            else {
//                NSLog(@"Error: MainViewController/viewDidLoad/startWithCompletionHandler");
//            }
//        }];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    NSLog(@"%@ // %@ // %@ // %@",[user name],[user objectID],[user objectForKey:@"email"],[user objectForKey:@"friends"]);
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"Logged In");
}

- (void)redirectToHome: (PFUser *) user {
    NSLog(@"Redirect");
//    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    HomeViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"homeViewController"];
//    vc.user = user;
    if (self.aboutMeViewController != nil) {
        [self dismissViewControllerAnimated:YES completion:^{[self.aboutMeViewController loggedInWith:user];}];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (IBAction)handleFacebookLogin:(id)sender {
    NSLog(@"handleFacebookLogin");
    NSArray *permissionsArray = @[ @"email",@"public_profile" ];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
            
            [self redirectToHome:user];
        }
    }];
    
    NSLog(@"Exiting handleFacebookLogin");
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"logIn"]) {
        LogInViewController *logInViewController = (LogInViewController *) segue.destinationViewController;
        logInViewController.mainViewController = self;
    }
}
@end
