//
//  MapViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-02.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "MapViewController.h"
#import "DEGeocodingServices.h"
#import "RestaurantDetailViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>

@interface MapViewController () <GMSMapViewDelegate,UISearchBarDelegate>

@end

@implementation MapViewController {
    GMSMapView *mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.distance = 5.0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentLongitude = [defaults objectForKey:@"currentLongitude"];
    NSString *currentLatitude = [defaults objectForKey:@"currentLatitude"];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[currentLatitude floatValue] longitude:[currentLongitude floatValue] zoom:14];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.delegate = self;
    self.view = mapView;
    
    
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshMapView:)];
    self.navigationItem.rightBarButtonItem = refresh;
    
    UIBarButtonItem *options = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(displayOptions:)];
    self.navigationItem.leftBarButtonItem = options;
    
    [self refreshRetrievedData:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshRetrievedData:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentLongitude = [defaults objectForKey:@"currentLongitude"];
    NSString *currentLatitude = [defaults objectForKey:@"currentLatitude"];
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:[currentLatitude floatValue] longitude:[currentLongitude floatValue]];
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurants"];
    [query whereKey:@"restaurantLocation" nearGeoPoint:point withinKilometers:self.distance];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self refreshMapView:objects];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

- (void)refreshRetrievedDataWithLocation:(CLLocation *)location andSearchOption:(NSString *)searchText {
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLocation:location];
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurants"];
    [query whereKey:@"restaurantLocation" nearGeoPoint:point withinKilometers:self.distance];
    if ((searchText) || (![searchText isEqual:@""])) {
        [query whereKey:@"restaurantName" containsString:searchText];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self refreshMapView:objects];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

- (void)refreshMapView:(NSArray *)objects {
    NSArray *colorArray = @[[UIColor greenColor],[UIColor yellowColor],[UIColor orangeColor],[UIColor redColor],[UIColor blackColor],[UIColor purpleColor]];
    
    for (PFObject *restaurant in objects) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        PFGeoPoint *restaurantPoint = [restaurant objectForKey:@"restaurantLocation"];
        marker.position = CLLocationCoordinate2DMake([restaurantPoint latitude],[restaurantPoint longitude]);
        marker.title = [restaurant objectForKey:@"restaurantName"];
        marker.snippet = [restaurant objectForKey:@"restaurantDescription"];
        NSString *priceIndex = [restaurant objectForKey:@"restaurantPrice"];
        NSInteger colorIndex = [priceIndex integerValue] - 1;
        if (!priceIndex) {
            colorIndex = 5;
        }
        marker.icon = [GMSMarker markerImageWithColor:colorArray[colorIndex]];
        marker.userData = restaurant;
        marker.map = mapView;
    }
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    if (marker.userData) {
        NSLog(@"Has Data");
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RestaurantDetailViewController *restaurantDetailViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"restaurantDetailViewController"];
        restaurantDetailViewController.restaurant = marker.userData;
        restaurantDetailViewController.currentLocation = [[CLLocation alloc] initWithLatitude:[[[NSUserDefaults standardUserDefaults] objectForKey:@"currentLatitude"] floatValue] longitude:[[[NSUserDefaults standardUserDefaults] objectForKey:@"currentLongitude"] floatValue]];
        [self.navigationController pushViewController:restaurantDetailViewController animated:YES];
    }
    else {
        NSLog(@"Does NOT have data");
    }
}

-(void) displayOptions:(id)sender {
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
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self refreshRetrievedDataWithLocation:[[CLLocation alloc] initWithLatitude:mapView.camera.target.latitude longitude:mapView.camera.target.longitude] andSearchOption:searchText];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.text = @"";
    [self refreshRetrievedData:nil];
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
