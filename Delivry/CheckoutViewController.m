//
//  CheckoutViewController.m
//  Delivry
//
//  Created by Bo Wen Hou on 2015-01-17.
//  Copyright (c) 2015 Eddie Hou. All rights reserved.
//
//  Changes Needed:
//  1. Fix: Move the picker views down a bit to make it prettier
//  2. Function: Pressing Delivry should show an alert to say it was successful and go back to cart page
//  3. Function: Make an address page and link change address
//  4. Function: Submission will include delivery time and charge to the correct credit card


#import "CheckoutViewController.h"
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>

const int BUTTONHEIGHT = 40;
const int MAPVIEWHEIGHT = 100;
const int SPECIALREQUESTHEIGHT = 100;
const int LABELHEIGHT = 20;
const int TIMEPICKERTAG = 0;
const int PAYMENTPICKERTAG = 1;

@interface CheckoutViewController () <GMSMapViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@end

@implementation CheckoutViewController {
    int yPosition;
    GMSMapView *mapView;
    NSDate *selectedDate;
    NSInteger selectedPayment;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadUserPaymentInfo];
    self.deliveryTime = [NSDate date];
    selectedDate = [NSDate date];
    selectedPayment = 0;
    [self initTimePickerBackView];
    [self initPaymentPickerBackView];
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"%f//%f",self.view.frame.size.height,self.view.frame.size.width);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-(20+self.navigationController.navigationBar.frame.size.height+44))];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 20+100+30+20+30+30+100+30);
    [self.view addSubview:self.scrollView];
    [self createViewForCheckout];
                                                                     
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Creation

- (void)createViewForCheckout {
    NSLog(@"started");
    UILabel *delivryAddressLabel = [self createLabelForCheckoutWithText:@"Delivry Address" frame:CGRectMake(0, yPosition, self.view.frame.size.width, 20)];
    yPosition += 20;
    [self.scrollView addSubview:delivryAddressLabel];
    
    // Map View of address
    UIView *addressMapView = [[UIView alloc] initWithFrame:CGRectMake(0, yPosition, self.view.frame.size.width, 100)];
    [self createMapViewForCheckoutWithView:addressMapView];
    yPosition += 100;
    [self.scrollView addSubview:addressMapView];
    
    UIButton *delivryAddressButton = [UIButton buttonWithType:UIButtonTypeCustom];
    delivryAddressButton.frame = CGRectMake(0, yPosition, self.view.frame.size.width, 30);
    [delivryAddressButton addTarget:self action:@selector(changeAddress:) forControlEvents:UIControlEventTouchUpInside];
    [delivryAddressButton setTitle:@"Delivry Address" forState:UIControlStateNormal];
    yPosition += 30;
    [self.scrollView addSubview:delivryAddressButton];
    
    UILabel *orderDetailsLabel = [self createLabelForCheckoutWithText:@"Order Details" frame:CGRectMake(0, yPosition, self.view.frame.size.width, 20)];
    yPosition += 20;
    [self.scrollView addSubview:orderDetailsLabel];
    
    UIButton *delivryTimeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    delivryTimeButton.frame = CGRectMake(0, yPosition, self.view.frame.size.width, 30);
    [delivryTimeButton addTarget:self action:@selector(changeTime:) forControlEvents:UIControlEventTouchUpInside];
    [delivryTimeButton setTitle:@"Delivry Time" forState:UIControlStateNormal];
    yPosition += 30;
    [self.scrollView addSubview:delivryTimeButton];
    
    UIButton *paymentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    paymentButton.frame = CGRectMake(0, yPosition, self.view.frame.size.width, 30);
    [paymentButton addTarget:self action:@selector(changePayment:) forControlEvents:UIControlEventTouchUpInside];
    [paymentButton setTitle:@"Payment" forState:UIControlStateNormal];
    yPosition += 30;
    [self.scrollView addSubview:paymentButton];
    
    UITextField *specialRequestTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, yPosition, self.view.frame.size.width, 100)];
    specialRequestTextField.text = @"Special Request";
    specialRequestTextField.backgroundColor = [UIColor lightGrayColor];
    specialRequestTextField.textAlignment = NSTextAlignmentNatural;
    yPosition += 100;
    [self.scrollView addSubview:specialRequestTextField];
    NSLog(@"ended");
    
    UIButton *delivryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    delivryButton.frame = CGRectMake(0, yPosition, self.view.frame.size.width, 30);
    [delivryButton addTarget:self action:@selector(delivry:) forControlEvents:UIControlEventTouchUpInside];
    [delivryButton setTitle:@"DELIVRY" forState:UIControlStateNormal];
    yPosition += 30;
    [self.scrollView addSubview:delivryButton];
}

- (void)createMapViewForCheckoutWithView:(UIView *)view {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentLongitude = [defaults objectForKey:@"currentLongitude"];
    NSString *currentLatitude = [defaults objectForKey:@"currentLatitude"];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[currentLatitude floatValue] longitude:[currentLongitude floatValue] zoom:14];
    mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) camera:camera];
    mapView.delegate = self;
    mapView.userInteractionEnabled = NO;
    [view addSubview:mapView];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([currentLatitude floatValue],[currentLongitude floatValue]);
    marker.map = mapView;
}

- (UILabel *)createLabelForCheckoutWithText:(NSString *)text frame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor darkGrayColor];
    return label;
}

#pragma mark - Button Functions

- (void)changeAddress:(id)sender {
    // go to address page
}

- (void)changeTime:(id)sender {
    [self.view addSubview:self.timePickerSubView];
}

-(void)timeSelected {
    self.deliveryTime = selectedDate;
    [self.timePickerSubView removeFromSuperview];
}

-(void)timeCanceled {
    [self.timePickerSubView removeFromSuperview];
}

- (void)changePayment:(id)sender {
    // go to credit card page
    [self.view addSubview:self.paymentPickerSubView];
}

-(void)paymentSelected {
    for (PFObject *object in self.userPaymentInfo) {
        if ([object objectForKey:@"selected"]) {
            [object setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
        }
    }
    PFObject *selectedPaymentObject = [self.userPaymentInfo objectAtIndex:selectedPayment];
    [selectedPaymentObject setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
    [PFObject saveAllInBackground:self.userPaymentInfo block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Info (Parse): Successfully saved user payment info.");
            [self.paymentPickerSubView removeFromSuperview];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}

-(void)paymentCanceled {
    [self.paymentPickerSubView removeFromSuperview];
}

- (void)delivry:(id)sender {
    // use cloud code to charge on token
    PFQuery *query = [PFQuery queryWithClassName:@"UserPaymentInfo"];
    [query whereKey:@"selected" equalTo:[NSNumber numberWithBool:true]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Info (Parse): Successfully retrieved payment information.");
            if (objects.count < 1) {
                NSLog(@"Alert: Please select a payment option or enter one.");
            }
            else {
                PFObject *object = [objects objectAtIndex:0];
                PFObject *token = [object objectForKey:@"token"];
                [PFCloud callFunctionInBackground:@"checkoutOrder" withParameters:@{@"tokenObjectId":token.objectId,@"totalPrice":[NSNumber numberWithDouble:self.totalPrice],@"transactionObjectId":self.transactionObject.objectId,@"currency":@"cad"} block:^(id object, NSError *error) {
                    if (!error) {
                        NSLog(@"Info (Parse Cloud): Successfully checkout order.");
                    }
                    else {
                        NSLog(@"Error (Parse Cloud): %@",error);
                    }
                }];
            }
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == TIMEPICKERTAG) {
        NSLog(@"Selected: %@",[self getDateTime:row]);
        selectedDate = [self getDateTime:row];
    }
    else if (pickerView.tag == PAYMENTPICKERTAG) {
        NSLog(@"Selected: %ld",(long)row);
        selectedPayment = row;
    }
    else {
        // do nothing
    }
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.frame.size.width;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = @"";
    if (pickerView.tag == TIMEPICKERTAG) {
        NSDate *destinationDate = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    
        title = [title stringByAppendingFormat:@"%@",[formatter stringFromDate:[self deliveryTimeFrom:destinationDate next:row]]];
        return title;
    }
    else if (pickerView.tag == PAYMENTPICKERTAG) {
        PFObject *userPaymentInfo = [self.userPaymentInfo objectAtIndex:row];
        title = [userPaymentInfo objectForKey:@"cardType"];
        title = [title stringByAppendingString:@" **** "];
        title = [title stringByAppendingString:[userPaymentInfo objectForKey:@"cardNumber"]];
        return title;
    }
    else {
        return title;
    }
}

-(NSDate *)getDateTime:(NSInteger)num {
    NSDate *destinationDate = [self getCurrentTimeZoneTime];
    
    return [self deliveryTimeFrom:destinationDate next:num];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == TIMEPICKERTAG) {
        NSDate *destinationDate = [NSDate date];
        NSDate *currentTime = [self deliveryTimeFrom:destinationDate next:0];
        NSDate *endTime = [self changeTime:destinationDate hourTo:23 minuteTo:0];
        NSTimeInterval interval = [endTime timeIntervalSinceDate:currentTime];
    
        return interval/(15*60);
    }
    else if (pickerView.tag == PAYMENTPICKERTAG) {
        return self.userPaymentInfo.count;
    }
    else {
        return 0; // error
    }
}

-(NSDate *)getCurrentTimeZoneTime {
    NSDate *sourceDate = [NSDate date];
    
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone *destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    return destinationDate;
}

-(NSDate *)changeTime:(NSDate *)date hourTo:(NSInteger)hour minuteTo:(NSInteger)minute {
    NSDateComponents *timeComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    if (hour >= 0) {
        [timeComponents setHour:hour];
    }
    if (minute >= 0) {
        [timeComponents setMinute:minute];
    }
    return [[NSCalendar currentCalendar] dateFromComponents:timeComponents];
}

-(NSDate *)deliveryTimeFrom:(NSDate *)date next:(NSInteger)next{
    NSDateComponents *timeComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    [timeComponents setMinute:((([timeComponents minute]+55)/15)+next)*15];
    return [[NSCalendar currentCalendar] dateFromComponents:timeComponents];
}

-(void)initTimePickerBackView {
    UIView *pickerBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [pickerBackView setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.4]];
    // go to time page
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 40)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(timeSelected)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(timeCanceled)];
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton,flex,doneButton, nil]];
    
    UIPickerView *timePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2+40, self.view.frame.size.width, self.view.frame.size.height/2-40)];
    timePicker.delegate = self;
    timePicker.dataSource = self;
    timePicker.showsSelectionIndicator = YES;
    timePicker.tag = TIMEPICKERTAG;
    [timePicker setBackgroundColor:[UIColor whiteColor]];
    
    [pickerBackView addSubview:timePicker];
    [pickerBackView addSubview:toolBar];
    self.timePickerSubView = pickerBackView;
}

-(void)initPaymentPickerBackView {
    UIView *pickerBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [pickerBackView setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.4]];
    // go to time page
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 40)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(paymentSelected)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(paymentCanceled)];
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton,flex,doneButton, nil]];
    
    UIPickerView *paymentPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2+40, self.view.frame.size.width, self.view.frame.size.height/2-40)];
    paymentPicker.delegate = self;
    paymentPicker.dataSource = self;
    paymentPicker.showsSelectionIndicator = YES;
    paymentPicker.tag = PAYMENTPICKERTAG;
    [paymentPicker setBackgroundColor:[UIColor whiteColor]];
    
    [pickerBackView addSubview:paymentPicker];
    [pickerBackView addSubview:toolBar];
    self.paymentPickerSubView = pickerBackView;
}

-(void)loadUserPaymentInfo {
    PFQuery *query = [PFQuery queryWithClassName:@"UserPaymentInfo"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Info (Parse): Successfully loaded user payment info.");
            self.userPaymentInfo = [objects mutableCopy];
        }
        else {
            NSLog(@"Error (Parse): %@",error);
        }
    }];
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
