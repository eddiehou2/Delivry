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
#import "FilterRestaurantViewController.h"
#import <Parse/Parse.h>

@interface RestaurantTableViewController ()

@end

@implementation RestaurantTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *filter = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonClicked:)];
    self.navigationItem.rightBarButtonItem = filter;
    
    self.priceIndex = 3;
    self.popular = NO;
    self.newlyOpen = NO;
    self.discountForLargeOrder = NO;
    self.distance = 5.0;
    self.distanceIndex = 3;
    self.sortBy = @"Distance";
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

-(void)viewDidAppear:(BOOL)animated {
    [self searchingWithFiltering];
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

- (void)filterButtonClicked:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FilterRestaurantViewController *filterRestaurantViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"filterRestaurantViewController"];
    filterRestaurantViewController.priceIndex = self.priceIndex;
    filterRestaurantViewController.popular = self.popular;
    filterRestaurantViewController.newlyOpen = self.newlyOpen;
    filterRestaurantViewController.distanceIndex = self.distanceIndex;
    filterRestaurantViewController.discountForLargeOrder = self.discountForLargeOrder;
    filterRestaurantViewController.sortByIndex = self.sortByIndex;
    
    filterRestaurantViewController.keywordFilter = self.keywordFilter;
    filterRestaurantViewController.addressFilter = self.addressFilter;
    [self.navigationController pushViewController:filterRestaurantViewController animated:YES];
}

- (void)savingFilteringsForPriceIndex:(NSInteger)priceIndex popular:(BOOL)popular newlyOpen:(BOOL)newlyOpen distance:(double)distance distanceIndex:(NSInteger)distanceIndex discountForLargeOrder:(BOOL)discountForLargeOrder sortBy:(NSString *)sortBy sortByIndex:(NSInteger)sortByIndex keywordFilter:(NSString *)keywordFilter addressFilter:(NSString *)addressFilter {
    self.priceIndex = priceIndex;
    self.popular = popular;
    self.newlyOpen = newlyOpen;
    self.distance = distance;
    self.distanceIndex = distanceIndex;
    self.discountForLargeOrder = discountForLargeOrder;
    self.sortBy = sortBy;
    self.sortByIndex = sortByIndex;
    
    self.keywordFilter = keywordFilter;
    self.addressFilter = addressFilter;
}

- (void)searchingWithFiltering {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *filterLatitude = [defaults objectForKey:@"filterLatitude"];
    NSString *filterLongitude = [defaults objectForKey:@"filterLongitude"];
    CLLocation *filterLocation = [[CLLocation alloc] initWithLatitude:[filterLatitude floatValue] longitude:[filterLongitude floatValue]];
    PFGeoPoint *filterPoint = [PFGeoPoint geoPointWithLocation:filterLocation];
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurants"];
    if (self.popular) {
        // more than 100 orders in the past month
    }
    
    if (self.newlyOpen) {
        // added less than 2 month ago
        int twoMonth = -60*60*24*60;
        NSDate *twoMonthAgo = [NSDate dateWithTimeIntervalSinceNow:twoMonth];
        [query whereKey:@"createdAt" greaterThanOrEqualTo:twoMonthAgo];
    }
    
    if (self.discountForLargeOrder) {
        // check discount table
        PFQuery *innerQuery = [PFQuery queryWithClassName:@"Discounts"];
        [innerQuery whereKey:@"discountType" equalTo:@"discountForLargeOrder"];
#warning not complete
    }
   
    if ([self.sortBy isEqualToString:@"Distance"]) {
        // sort by distance by default
    }
    else if ([self.sortBy isEqualToString:@"Price"]) {
        // sort by price
        [query orderByAscending:@"restaurantPrice"];
    }
    [query whereKey:@"restaurantLocation" nearGeoPoint:filterPoint withinKilometers:self.distance];
    [query whereKey:@"restaurantPrice" lessThanOrEqualTo:[NSNumber numberWithLong:self.priceIndex+1]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.restaurants = objects;
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error (Parse): %@", error);
        }
    }];
}



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
