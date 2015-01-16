//
//  FilterRestaurantViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-10.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "FilterRestaurantViewController.h"
#import "RestaurantTableViewController.h"
#import "DEGeocodingServices.h"

@interface FilterRestaurantViewController () <UISearchBarDelegate,CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@end

@implementation FilterRestaurantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    locationManager = [[CLLocationManager alloc] init];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height+20, self.navigationController.navigationBar.frame.size.width, 44)];
    self.searchBar.searchBarStyle = UISearchBarStyleDefault;
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    self.locationBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height+20+self.searchBar.frame.size.height, self.navigationController.navigationBar.frame.size.width, 44)];
    self.locationBar.searchBarStyle = UISearchBarStyleDefault;
    self.locationBar.delegate = self;
    [self.view addSubview:self.locationBar];
    
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStyleDone target:self action:@selector(searchWithFilter:)];
    self.navigationItem.rightBarButtonItem = search;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)viewDidAppear:(BOOL)animated {
    [self.priceSegmentControl setSelectedSegmentIndex:self.priceIndex];
    self.popularSwitch.on = self.popular;
    self.newlyOpenSwitch.on = self.newlyOpen;
    [self.distanceSegmentControl  setSelectedSegmentIndex:self.distanceIndex];
    self.discountForLargeOrderSwitch.on = self.discountForLargeOrder;
    [self.sortBySegmentControl setSelectedSegmentIndex:self.sortByIndex];
    [self updateLocation: nil];
    
    self.searchBar.text = self.keywordFilter;
    self.locationBar.text = self.addressFilter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateLocation:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    NSLog(@"Start Updating Location");
    
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    
    NSLog(@"Stop Updating Location");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"locationManager didFailWithError: %@", error);
    [self alertMessage:@"Failed to get your location! Please turn on location for this App." title:@"Error:"];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations objectAtIndex:locations.count-1];
    NSLog(@"locationManager didUpdateToLocation: %@",currentLocation);
    
    if (currentLocation != nil) {
        [self updateFilterLocation:currentLocation withAddress:@"Current Location"];
        self.currentLocation = currentLocation;
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
}

- (void) alertMessage:(NSString *)message title:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)searchWithFilter:(id)sender {
    NSString *sortBy = [self.sortBySegmentControl titleForSegmentAtIndex:self.sortBySegmentControl.selectedSegmentIndex];
    NSString *distance = [self.distanceSegmentControl titleForSegmentAtIndex:self.distanceSegmentControl.selectedSegmentIndex];
    
    RestaurantTableViewController *restaurantTableViewController = (RestaurantTableViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    [restaurantTableViewController savingFilteringsForPriceIndex:self.priceSegmentControl.selectedSegmentIndex popular:self.popularSwitch.isOn newlyOpen:self.newlyOpenSwitch.isOn distance:[[distance substringToIndex:distance.length-3] floatValue] distanceIndex:self.distanceSegmentControl.selectedSegmentIndex discountForLargeOrder:self.discountForLargeOrderSwitch.isOn sortBy:sortBy sortByIndex:self.sortBySegmentControl.selectedSegmentIndex keywordFilter:self.keywordFilter addressFilter:self.addressFilter];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (searchBar == self.locationBar) {
        if ([searchBar.text isEqualToString: @""] || [searchBar.text isEqualToString:@"Current Location"]) {
            searchBar.text = @"Current Location";
            [self updateFilterLocation:self.currentLocation withAddress:@"Current Location"];
        }
        else {
            DEGeocodingServices *geocoder = [[DEGeocodingServices alloc] init];
            [geocoder geocodeAddress:searchBar.text];
            if (geocoder.geocode) {
                CLLocation *filterLocation = [[CLLocation alloc] initWithLatitude:[[geocoder.geocode objectForKey:@"lat"] floatValue] longitude:[[geocoder.geocode objectForKey:@"lng"] floatValue]];
                [self updateFilterLocation:filterLocation withAddress:[geocoder.geocode objectForKey:@"address"]];
            }
        }
        self.addressFilter = searchBar.text;
    }
    else if (searchBar == self.searchBar) {
        self.keywordFilter = searchBar.text;
    }
}

- (void)dismissKeyboard {
    [self.searchBar resignFirstResponder];
    [self.locationBar resignFirstResponder];
}

- (void)updateFilterLocation:(CLLocation *)filterLocation withAddress:(NSString *)address {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSString stringWithFormat:@"%.8f", filterLocation.coordinate.longitude] forKey:@"filterLongitude"];
    [defaults setObject:[NSString stringWithFormat:@"%.8f", filterLocation.coordinate.latitude] forKey:@"filterLatitude"];
    [defaults setObject:address forKey:@"filterAddress"];
    [defaults synchronize];
}

/*
 display the follow options:
 price($ to $$$$$)
 open now(show or hide)
 popular(show or hide)
 new(show or hide)
 distance(0.5km, 2km, 5km, 10km, 20km)
 discounts for large orders(show or hide)
 
 sort by(price, distance)
 
 cancel button and search button
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
