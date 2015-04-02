//
//  DEGeocodingServices.h
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-02.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DEGeocodingServices : NSObject <NSURLConnectionDelegate>

- (id) init;
- (void)geocodeAddress: (NSString *) address;
+ (NSDictionary *)findPathingBetween:(NSString *)origin to:(NSString *)destination;
- (void)getAutocomplete:(NSString *)address;

@property (nonatomic, strong) NSDictionary *geocode;
@property (nonatomic, strong) NSMutableArray *predictions;

@end
