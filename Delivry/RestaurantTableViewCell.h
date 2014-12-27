//
//  RestaurantTableViewCell.h
//  Delivry
//
//  Created by Shuo-Min Amy Fan on 2014-12-26.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *minimumLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;


@end
