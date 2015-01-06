//
//  DEGeocodingServices.h
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-02.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DEGeocodingServices : NSObject

- (id) init;
- (void)geocodeAddress: (NSString *) address;

@property (nonatomic, strong) NSDictionary *geocode;

@end
