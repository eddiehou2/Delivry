//
//  AddressViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-12.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//
//  Change Needed:
//  1. tableView cellAtRow is not working properly and gets error when switching back after load


#import "AddressViewController.h"
#import "AddAddressViewController.h"
#import "AddressTableViewCell.h"
#import <Parse/Parse.h>

@interface AddressViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation AddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addAddress:)];
    self.navigationItem.rightBarButtonItem = add;
    
    int statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.addressTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, statusBarHeight+self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-(statusBarHeight+self.navigationController.navigationBar.frame.size.height+self.tabBarController.tabBar.frame.size.height))];
    self.addressTableView.delegate = self;
    self.addressTableView.dataSource = self;
    [self.view addSubview:self.addressTableView];
}

-(void)viewDidAppear:(BOOL)animated {
    PFQuery *addressQuery = [PFQuery queryWithClassName:@"UserAddress"];
    [addressQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Parse (Info): Successfully find all addresses.");
            self.addresses = [objects mutableCopy];
        }
        else {
            NSLog(@"Parse (Error): %@",error);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addAddress:(id)sender {
    AddAddressViewController *addAddressViewController = [[AddAddressViewController alloc] init];
    [self.navigationController pushViewController:addAddressViewController animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (cell == nil) {
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"Cell" bundle:nil];
        cell = (AddressTableViewCell *)temporaryController.view;
    }
    
    PFObject *address = [self.addresses objectAtIndex:indexPath.row];
    cell.addressTitle.text = [address objectForKey:@"address"];
    cell.selectedImage.image = [[UIImage alloc] init];
    if ([address objectForKey:@"selected"]) {
        cell.selectedImage.backgroundColor = [UIColor redColor];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addresses.count;
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
