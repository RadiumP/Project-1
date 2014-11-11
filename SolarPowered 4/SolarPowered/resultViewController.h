//
//  resultViewController.h
//  project
//
//  Created by Young Lee on 10/31/14.
//  Copyright (c) 2014 YoungLee. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@interface resultViewController : ViewController<NSXMLParserDelegate>
@property NSNumber *latitude;
@property NSNumber *longitude;
@property NSNumber *utilityRate;
@property NSNumber *estMonthlyBill;
@property NSNumber *energyUsedNew;
@property NSNumber *energyBillNew;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;
@property (weak, nonatomic) IBOutlet UILabel *billnewLabel;
@property (weak, nonatomic) IBOutlet UILabel *billLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;

+(resultViewController*)init;

@end
