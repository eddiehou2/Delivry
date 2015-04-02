//
//  AddAddressViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-12.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "AddAddressViewController.h"
#import "DEGeocodingServices.h"
#import <Parse/Parse.h>

@interface AddAddressViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation AddAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height+20, self.navigationController.navigationBar.frame.size.width, 44)];
    self.searchBar.showsCancelButton = YES;
    self.searchBar.searchBarStyle = UISearchBarStyleDefault;
    self.searchBar.delegate = self;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.frame.size.height+self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-([UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.frame.size.height+self.searchBar.frame.size.height+self.tabBarController.tabBar.frame.size.height))];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    
    self.autocomplete = [[DEGeocodingServices alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.autocomplete getAutocomplete:searchText];
    self.predictions = self.autocomplete.predictions;
    NSLog(@"searchbar changed: %lu", (unsigned long)self.predictions.count);
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    // Configure the cell...
    cell.textLabel.text = [self.predictions objectAtIndex:indexPath.row];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.predictions.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFQuery *address = [PFQuery queryWithClassName:@"UserAddress"];
    [address whereKey:@"selected" equalTo:[NSNumber numberWithBool:YES]];
    NSMutableArray *saveAllAddresses = [[NSMutableArray alloc] init];
    [address findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Parse (Info): Successfully found all addresses.");
            for (PFObject *object in objects) {
                [object setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
                [saveAllAddresses addObject:object];
            }
            [PFObject saveAllInBackground:saveAllAddresses block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Parse (Info): Successfully saved all addresses to selected equals false.");
                    PFQuery *addressCheck = [PFQuery queryWithClassName:@"UserAddress"];
                    [addressCheck whereKey:@"address" equalTo:[self.predictions objectAtIndex:indexPath.row]];
                    [addressCheck findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error) {
                            NSLog(@"Parse (Info): Successfully found address check.");
                            if (objects.count > 0) {
                                PFObject *address = objects[0];
                                [address setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
                                [address saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (succeeded) {
                                        NSLog(@"Parse (Info): Successfully saved old address.");
                                        [self.navigationController popViewControllerAnimated:YES];
                                    }
                                    else {
                                        NSLog(@"Parse (Error): %@",error);
                                    }
                                }];
                            }
                            else {
                                PFObject *newAddress = [PFObject objectWithClassName:@"UserAddress"];
                                [newAddress setObject:[PFUser currentUser] forKey:@"user"];
                                [newAddress setObject:[self.predictions objectAtIndex:indexPath.row] forKey:@"address"];
                                [newAddress setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
                                NSLog(@"user: %@",[PFUser currentUser]);
                                [newAddress setACL:[PFACL ACLWithUser:[PFUser currentUser]]];
                                [newAddress saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (succeeded) {
                                        NSLog(@"Parse (Info): Successfully saved new address.");
                                        [self.navigationController popViewControllerAnimated:YES];
                                    }
                                    else {
                                        NSLog(@"Parse (Error): %@",error);
                                    }
                                }];
                            }
                        }
                        else {
                            NSLog(@"Parse (Error): %@",error);
                        }
                    }];
                    
                }
                else {
                    NSLog(@"Parse (Error): %@",error);
                }
            }];
        }
        else {
            NSLog(@"Parse (Error): %@",error);
        }
    }];
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
