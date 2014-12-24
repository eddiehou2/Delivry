//
//  LogInViewController.h
//  Delivry
//
//  Created by Eddie Hou on 2014-11-28.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LogInViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)logInUser:(id)sender;
- (IBAction)cancelled:(id)sender;


@end
