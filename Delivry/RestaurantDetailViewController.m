//
//  RestaurantDetailViewController.m
//  Delivry
//
//  Created by Eddie Hou on 2014-12-27.
//  Copyright (c) 2014 Eddie Hou. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import <Parse/Parse.h>

@interface RestaurantDetailViewController ()

@end

@implementation RestaurantDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.image.image = [UIImage imageNamed:@"app_icon"];
    self.nameLabel.text = [self.restaurant objectForKey:@"restaurantName"];
    self.descriptionLabel.text = [self.restaurant objectForKey:@"restaurantDescription"];
    self.priceLabel.text = [NSString stringWithFormat:@"%@/5",[self.restaurant objectForKey:@"restaurantPrice"]];
    self.minimumLabel.text = [NSString stringWithFormat:@"$%@+",[self.restaurant objectForKey:@"restaurantMinimum"]];
    PFGeoPoint *point = [PFGeoPoint geoPointWithLocation:self.currentLocation];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f km",[point distanceInKilometersTo:[self.restaurant objectForKey:@"restaurantLocation"]]];
    
    NSInteger noItems = rand() % 20 + 30;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.image.bounds.size.height + self.navigationController.navigationBar.frame.size.height + 10, self.view.bounds.size.width, self.view.bounds.size.height-(self.image.bounds.size.height + self.navigationController.navigationBar.frame.size.height + self.tabBarController.tabBar.frame.size.height + 10))];
    [scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width, noItems*25 + 40)];
    for (int i = 0; i < noItems; i++) {
        UILabel *item = [[UILabel alloc] initWithFrame:CGRectMake(10, i*25, (3/4.0)*(scrollView.bounds.size.width - 10), 21)];
        item.text = [NSString stringWithFormat:@"Item %i",i];
        item.tag=4 * i;
        [scrollView addSubview:item];
        
        UILabel *quantity = [[UILabel alloc] initWithFrame:CGRectMake((3/4.0)*(scrollView.bounds.size.width - 10)+10+50, i*25, (1/4.0)*(scrollView.bounds.size.width - 10)-50, 21)];
        quantity.text = @"0";
        quantity.tag=4 * i + 1;
        [scrollView addSubview:quantity];
        
        UIButton *add = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        add.frame = CGRectMake((3/4.0)*(scrollView.bounds.size.width - 10)+10, i*25, 21, 21);
        [add setTitle:@"+" forState:UIControlStateNormal];
        add.tag=4 * i + 2;
        [add addTarget:self action:@selector(increaseItemQuantity:) forControlEvents:UIControlEventTouchUpInside];
        add.enabled = YES;
        [scrollView addSubview:add];
        
        UIButton *minus = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        minus.frame = CGRectMake((3/4.0)*(scrollView.bounds.size.width - 10)+10+25, i*25, 21, 21);
        [minus setTitle:@"-" forState:UIControlStateNormal];
        minus.tag=4 * i + 3;
        [minus addTarget:self action:@selector(decreaseItemQuantity:) forControlEvents:UIControlEventTouchUpInside];
        minus.enabled = NO;
        [scrollView addSubview:minus];
    }
    UIButton *submit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submit.frame = CGRectMake(scrollView.bounds.size.width - 110, noItems*25+5, 100, 30);
    [submit setTitle:@"Submit" forState:UIControlStateNormal];
    [scrollView addSubview:submit];
    
    [self.view addSubview:scrollView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) increaseItemQuantity:(id) sender{
    UIButton *add = (UIButton *) sender;
    UILabel *label = (UILabel *) [self.view viewWithTag:(add.tag-1)];
    label.text = [NSString stringWithFormat:@"%i",([label.text intValue]+1)];
    if ([label.text intValue] > 0) {
        UIButton *minus = (UIButton *) [self.view viewWithTag:(add.tag+1)];
        minus.enabled = YES;
    }
}

-(void) decreaseItemQuantity:(id) sender{
    UIButton *minus = (UIButton *) sender;
    UILabel *label = (UILabel *) [self.view viewWithTag:(minus.tag-2)];
    label.text = [NSString stringWithFormat:@"%i",([label.text intValue]-1)];
    if ([label.text intValue] < 1) {
        minus.enabled = NO;
    }
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
