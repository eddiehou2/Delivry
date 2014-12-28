//
//  RestaurantTableViewController.m
//  Delivry
//
//  Created by Shuo-Min Amy Fan on 2014-12-24.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "RestaurantTableViewController.h"
#import "RestaurantTableViewCell.h"
#import "RestaurantDetailViewController.h"
#import <Parse/Parse.h>

@interface RestaurantTableViewController ()

@end

@implementation RestaurantTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    PFGeoPoint *currentPont = [PFGeoPoint geoPointWithLocation:self.currentLocation];
//    
//    PFQuery *query = [PFQuery queryWithClassName:@"Restaurants"];
//    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//    [query whereKey:@"restaurantLocation" nearGeoPoint:currentPont withinKilometers:5.0f];
//    [query orderByDescending:@"restaurantName"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
//        if (query.cachePolicy != kPFCachePolicyCacheOnly && error.code == kPFErrorCacheMiss) {
//            return;
//        }
//        
//        self.restaurants = objects;
//        NSLog(@"%@",objects);
//        
//    }];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //NSLog(@"%@",self.restaurants);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.restaurants count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.image.image = [UIImage imageNamed:@"app_image"];
    cell.nameLabel.text = [[self.restaurants objectAtIndex:indexPath.row] objectForKey:@"restaurantName"];
    cell.descriptionLabel.text = [[self.restaurants objectAtIndex:indexPath.row] objectForKey:@"restaurantDescription"];
    
    cell.priceLabel.text = [NSString stringWithFormat:@"%@/5",[[self.restaurants objectAtIndex:indexPath.row] objectForKey:@"restaurantPrice"]];
    cell.minimumLabel.text = [NSString stringWithFormat:@"$%@+",[[self.restaurants objectAtIndex:indexPath.row] objectForKey:@"restaurantMinimum"]];
    PFGeoPoint *point = [[self.restaurants objectAtIndex:indexPath.row] objectForKey:@"restaurantLocation"];
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.2f km",[point distanceInKilometersTo:[PFGeoPoint geoPointWithLocation:self.currentLocation]]];
    
    
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual: @"showRestaurantDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RestaurantDetailViewController *rdvc = [segue destinationViewController];
        rdvc.restaurant = [self.restaurants objectAtIndex:indexPath.row];
        rdvc.currentLocation = self.currentLocation;
    }
}


@end
