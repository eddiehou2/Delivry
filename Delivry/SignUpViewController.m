//
//  SignUpViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-11-28.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "SignUpViewController.h"
#import "LogInViewController.h"

@interface SignUpViewController ()

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
            }
            else {
                [self alertMessage:@"Something went wrong! Please try again." title:@"Error:"];
            }
        }];
        [self successfulSignUp:user.username];
        
    }
}

- (IBAction)cancelled:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) successfulSignUp:(NSString *) username {
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LogInViewController *logInViewControl = [mainStoryBoard instantiateViewControllerWithIdentifier:@"logInViewController"];
    logInViewControl.usernameField.text = username;
    [self presentViewController:logInViewControl animated:YES completion:nil];
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
