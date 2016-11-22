//
//  HistoryViewController.m
//  SolarPowered
//
//  Created by Young Lee on 11/28/14.
//  Copyright (c) 2014 jkhart1. All rights reserved.
//

#import "HistoryViewController.h"

@implementation HistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *bgImage = [UIImage imageNamed: @"Background3.png"];       // load image
    self.backgroundImageView = [[UIImageView alloc] initWithImage:bgImage];     // initialize image view with image
    [self.backgroundImageView sizeToFit];                           // scale image to fit frame
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect frame = self.backgroundImageView.frame;
    float imgFactor = frame.size.height / frame.size.width;         // configure frame settings
    frame.size.width = [[UIScreen mainScreen] bounds].size.width;
    frame.size.height = frame.size.width * imgFactor;
    self.backgroundImageView.frame = frame;
    [self.view addSubview:self.backgroundImageView];            // add image view as subview to main view
    [self.view sendSubviewToBack:self.backgroundImageView];     // send image to background so it doesn't cover objects
    
    self.costLabel.text = self.cost;
    self.resultLabel.text = self.result;
    self.billnewLabel.text = self.billnew;
    self.billLabel.text = self.bill;
    self.totalLabel.text = self.total;
}

@end
