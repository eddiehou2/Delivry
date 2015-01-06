//
//  MapViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-02.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import "MapViewController.h"
#import "DEGeocodingServices.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>

@interface MapViewController ()

@end

@implementation MapViewController {
    GMSMapView *mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray *colorArray = @[[UIColor greenColor],[UIColor yellowColor],[UIColor orangeColor],[UIColor redColor],[UIColor blackColor]];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentLongitude = [defaults objectForKey:@"currentLongitude"];
    NSString *currentLatitude = [defaults objectForKey:@"currentLatitude"];
    NSLog(@"lat: %@ // long: %@",currentLatitude, currentLongitude);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[currentLatitude floatValue] longitude:[currentLongitude floatValue] zoom:14];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    self.view = mapView;
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:[currentLatitude floatValue] longitude:[currentLongitude floatValue]];
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurants"];
    [query whereKey:@"restaurantLocation" nearGeoPoint:point withinKilometers:5.0];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        for (NSDictionary *restaurant in objects) {
            if (!error) {
                GMSMarker *marker = [[GMSMarker alloc] init];
                PFGeoPoint *restaurantPoint = [restaurant objectForKey:@"restaurantLocation"];
                marker.position = CLLocationCoordinate2DMake([restaurantPoint latitude], [restaurantPoint longitude]);
                marker.title = [restaurant objectForKey:@"restaurantName"];
                marker.snippet = [restaurant objectForKey:@"restaurantDescription"];
                NSString *priceIndex = [restaurant objectForKey:@"restaurantPrice"];
                NSInteger colorIndex = [priceIndex integerValue] - 1;
                marker.icon = [GMSMarker markerImageWithColor:colorArray[colorIndex]];
                marker.map = mapView;
            }
            else {
                NSLog(@"Error: MapViewController/viewDidLoad/findObjectsInBackgroundWithBlock");
            }
        }
    }];
    
    // Creates a marker in the center of the map
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([currentLatitude floatValue], [currentLongitude floatValue]);
    marker.title = @"Home";
    marker.snippet = @"Murano";
    marker.icon = [GMSMarker markerImageWithColor:[UIColor whiteColor]];
    marker.map = mapView;
    
    NSLog(@"Finish Loading Map");
    
    DEGeocodingServices *geocoder = [[DEGeocodingServices alloc] init];
    [geocoder geocodeAddress:@"770 Bay St., Toronto, ON"];
    GMSMarker *marker2 = [[GMSMarker alloc] init];
    marker2.position = CLLocationCoordinate2DMake([[geocoder.geocode objectForKey:@"lat"] floatValue], [[geocoder.geocode objectForKey:@"lng"] floatValue]);
    marker2.title = @"Amy's Home";
    marker2.snippet = @"Lumiere";
    marker2.icon = [GMSMarker markerImageWithColor:[UIColor whiteColor]];
    marker2.map = mapView;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
