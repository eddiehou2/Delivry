//
//  SignUpViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-11-28.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "SignUpViewController.h"
#import "LogInViewController.h"

@interface SignUpViewController () <UITextFieldDelegate>

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)signUpUser:(id)sender {
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
    else if (self.emailField.text.length < 8) {
        message = @"Email has to be a valid email address! Please try again.";
        [self alertMessage:message title:title];
    }
    else {
        PFUser *user = [PFUser user];
        PFRole *role = [PFRole roleWithName:@"Admin"];
        [role users];
        user.username = self.usernameField.text;
        user.password = self.passwordField.text;
        user.email = self.emailField.text;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self alertMessage:@"You have successfully signed up! Please confirm your email." title:@"Success:"];
                [self successfulSignUp:user.username];
            }
            else {
                [self alertMessage:@"Something went wrong! Please try again." title:@"Error:"];
            }
        }];
        
    }
}

- (IBAction)cancelled:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) successfulSignUp:(NSString *) username {
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LogInViewController *logInViewControl = [mainStoryBoard instantiateViewControllerWithIdentifier:@"logInViewController"];
    logInViewControl.usernameField.text = username;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) alertMessage:(NSString *)message title:(NSString *)title {
    self.alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.alertController addAction:ok];
    
    [self presentViewController:self.alertController animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}
@end
