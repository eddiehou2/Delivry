//
//  LogInViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-11-28.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "LogInViewController.h"
#import "HomeViewController.h"
#import "MainViewController.h"

@interface LogInViewController ()

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.usernameField.text = @"test1";
    self.passwordField.text = @"12345";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)logInUser:(id)sender {
    NSString *message;
    NSString *title = @"Error:";
    
    if (self.usernameField.text.length < 4) {
        message = @"Username has to be longer than 3 characters! Please try again.";
        [self alertMessage:message title:title];
    }
    else if (self.usernameField.text.length > 32) {
        message = @"Username has to be shorter than 32 characters! Please try again.";
        [self alertMessage:message title:title];
    }
    else if (self.passwordField.text.length < 5) {
        message = @"Password has to be longer than 4 characters! Please try again.";
        [self alertMessage:message title:title];
    }
    else if (self.passwordField.text.length > 32) {
        message = @"Password has to be shorter than 32 characters! Please try again.";
        [self alertMessage:message title:title];
    }
    else {
        [PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
            if ([user isAuthenticated]) {
                [self successfulLogIn:user];
            }
            else {
                [self alertMessage:@"The information entered was incorrect! Please try again." title:@"Error:"];
            }
            
            return;
        }];
        
    }
}

- (IBAction)cancelled:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) successfulLogIn:(PFUser *) user {
//    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    HomeViewController *vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"homeViewController"];
//    vc.user = user;
    MainViewController *mainViewController = (MainViewController *) self.navigationController.parentViewController;
    [self dismissViewControllerAnimated:YES completion:^{[mainViewController redirectToHome:user];}];
}

- (void) alertMessage:(NSString *)message title:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
