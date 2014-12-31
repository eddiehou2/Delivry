//
//  AboutMeViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-12-29.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "AboutMeViewController.h"
#import "MainViewController.h"
#import "PFUser+CurrentInformation.h"

@interface AboutMeViewController ()

@end

@implementation AboutMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [PFUser logOut];
    self.user = [PFUser currentUser];
    NSLog(@"%@",self.user);
    if (self.user == nil) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainViewController *mainViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainViewController"];
        mainViewController.aboutMeViewController = self;
        [self presentViewController:mainViewController animated:YES completion:nil];
    }
    // Do any additional setup after loading the view.
    
    [self addObserver:self forKeyPath:@"self.user.name" options:NSKeyValueObservingOptionNew context:NULL];
    
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkingItOut)];
    touch.numberOfTapsRequired = 2;
    touch.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:touch];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loggedInWith:(PFUser *) user {
    self.user = [PFUser getInformationFromCurrentUser];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"self.user.name"]) {
        self.name.text = self.user.name;
    }
}

- (void)checkingItOut {
    NSLog(@"33%@",self.user);
    NSLog(@"44%@",self.user.name);
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
