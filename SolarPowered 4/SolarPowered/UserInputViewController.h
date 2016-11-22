//
//  UserInputViewController.h
//  SolarPowered
//
//  Created by James Hart.
//  Copyright (c) 2014 jkhart1. All rights reserved.
//

#import "ViewController.h"

@interface UserInputViewController:ViewController

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property NSNumber *latitude;
@property NSNumber *longitude;
@property NSString *zipCode;
@property (weak, nonatomic) IBOutlet UILabel *zipCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *monthlyUsageTF;
@property (weak, nonatomic) IBOutlet UITextField *areaPanelsTF;

@property (weak, nonatomic) IBOutlet UILabel *errorCheckLabel;

@end