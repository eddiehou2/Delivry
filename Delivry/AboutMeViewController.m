//
//  AboutMeViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-12-29.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "AboutMeViewController.h"
#import "MainViewController.h"
#import "DEUser.h"

@interface AboutMeViewController ()

@end

@implementation AboutMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [PFUser logOut];
    self.user = [DEUser currentUser];
    NSLog(@"%@",self.user);
    if (self.user == nil) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainViewController"];
        mainViewController.aboutMeViewController = self;
        [self presentViewController:mainViewController animated:YES completion:nil];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loggedInWith:(PFUser *) user {
    self.user = [DEUser getInformationFromCurrentUser];
    NSLog(@"%@",self.user);
    NSLog(@"%@",self.user.name);
    self.name.text = self.user.name;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
