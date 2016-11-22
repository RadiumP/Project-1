//
//  HistoryViewController.h
//  SolarPowered
//
//  Created by Young Lee on 11/28/14.
//  Copyright (c) 2014 jkhart1. All rights reserved.
//

#import "ViewController.h"

@interface HistoryViewController : ViewController

@property NSString *cost;
@property NSString *billnew;
@property NSString *bill;
@property NSString *result;
@property NSString *total;

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UILabel *billnewLabel;
@property (weak, nonatomic) IBOutlet UILabel *billLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
