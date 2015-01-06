//
//  DEGeocodingServices.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-02.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

#import "DEGeocodingServices.h"

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
        [self fetchedData:data];
    });
}

- (void) fetchedData:(NSData *)data {
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


@end
