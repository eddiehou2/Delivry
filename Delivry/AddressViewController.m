//
//  AddressViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-12.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "AddressViewController.h"
#import <Parse/Parse.h>

@interface AddressViewController ()

@end

@implementation AddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addAddress:)];
    self.navigationItem.rightBarButtonItem = add;
    
    for (PFObject *object in self.addresses) {
        NSString *address = [object objectForKey:@"address"];
        NSString *addressName = [object objectForKey:@"addressName"];
        [self createAddressCellWithAddress:address addressName:addressName];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createAddressCellWithAddress:(NSString *)address addressName:(NSString *)addressName {
    long delta = self.addressCells.count*60 + 44;
    UIButton *addressButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addressButton.frame = CGRectMake(0, delta, self.view.frame.size.width, 60);
    
    UILabel *addressNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, addressButton.frame.size.width, addressButton.frame.size.height/2)];
    addressNameLabel.text = addressName;
    addressNameLabel.font = [UIFont systemFontOfSize:18];
    [addressButton addSubview:addressNameLabel];
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, addressNameLabel.frame.size.height, addressButton.frame.size.width-10, addressButton.frame.size.height/2)];
    addressLabel.text = address;
    addressLabel.font = [UIFont systemFontOfSize:14];
    [addressButton addSubview:addressLabel];
    
    addressButton.tag = self.addressCells.count;
    [self.view addSubview:addressButton];
    [self.addressCells addObject:addressButton];
}

- (void)addAddress:(id)sender {
    
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
