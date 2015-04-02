//
//  AddressTableViewCell.h
//  Delivry
//
//  Created by Bo Wen Hou on 2015-04-01.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *addressTitle;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;

@end
