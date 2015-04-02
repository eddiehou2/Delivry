//
//  DEGeocodingServices.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-02.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

#import "DEGeocodingServices.h"

const NSString *webKey = @"AIzaSyAvpcnGjOPx_ZfCDOtxLD7H7AeFOWiReG4";

@implementation DEGeocodingServices {
    NSData *_data;
}

@synthesize geocode;

- (id) init {
    self = [super init];
    geocode = [[NSDictionary alloc] init];
    return self;
}
- (void) geocodeAddress:(NSString *)address {
    NSString *geocodingBaseUrl = @"http://maps.googleapis.com/maps/api/geocode/json?";
    NSString *url = [NSString stringWithFormat:@"%@address=%@&sensor=false",geocodingBaseUrl,address];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *queryURL = [NSURL URLWithString:url];
    dispatch_sync(kBgQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:queryURL];
        [self fetchedDataGeocode:data];
    });
}

- (void) getAutocomplete:(NSString *)address {
    NSString *geocodingBaseUrl = @"https://maps.googleapis.com/maps/api/place/autocomplete/json?";
    NSString *url = [NSString stringWithFormat:@"%@input=%@&types=geocode&language=en&key=%@",geocodingBaseUrl,address,webKey];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *queryURL = [NSURL URLWithString:url];
    dispatch_sync(kBgQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:queryURL];
        [self fetchedDataAutocomplete:data];
    });
}

- (void) fetchedDataGeocode:(NSData *)data {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSArray *results = [json objectForKey:@"results"];
    NSDictionary *result = [results objectAtIndex:0];
    NSString *address = [result objectForKey:@"formatted_address"];
    NSDictionary *geometry = [result objectForKey:@"geometry"];
    NSDictionary *location = [geometry objectForKey:@"location"];
    NSString *lat = [location objectForKey:@"lat"];
    NSString *lng = [location objectForKey:@"lng"];
    
    NSDictionary *gc = [[NSDictionary alloc] initWithObjectsAndKeys:lat,@"lat",lng,@"lng",address,@"address", nil];
    
    geocode = gc;
}

- (void) fetchedDataAutocomplete:(NSData *)data {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSMutableArray *predictions = [[NSMutableArray alloc] init];
    
    NSArray *results = [json objectForKey:@"predictions"];
    for (NSDictionary *result in results) {
        NSString *description = [result objectForKey:@"description"];
        [predictions addObject:description];
    }
    
    self.predictions = predictions;
}

+ (NSDictionary *)findPathingBetween:(NSString *)origin to:(NSString *)destination {
    NSString *findingPathBaseUrl = @"http://maps.googleapis.com/maps/api/directions/json?";
    NSString *url = [NSString stringWithFormat:@"%@origin=%@&destination=%@&mode=%@&key=%@",findingPathBaseUrl,origin,destination,@"DRIVING",webKey];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *queryURL = [NSURL URLWithString:url];
    NSData *data = [NSData dataWithContentsOfURL:queryURL];
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray *routes = [json objectForKey:@"routes"];
    NSDictionary *route = [routes objectAtIndex:0];
    NSArray *legs = [route objectForKey:@"legs"];
    NSDictionary *leg = [legs objectAtIndex:0];
    NSDictionary *distance = [leg objectForKey:@"distance"];
    NSDictionary *duration = [leg objectForKey:@"duration"];
    return @{@"distance":[distance objectForKey:@"value"],@"duration":[duration objectForKey:@"value"]};
}



@end
