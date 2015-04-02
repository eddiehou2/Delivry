//
//  AddAddressViewController.h
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-12.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DEGeocodingServices;

@interface AddAddressViewController : UIViewController

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *predictions;
@property (nonatomic, strong) DEGeocodingServices *autocomplete;


@end
