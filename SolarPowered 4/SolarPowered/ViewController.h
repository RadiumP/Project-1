//
//  ViewController.h
//  project
//
//  Created by Young Lee on 10/30/14.
//  Copyright (c) 2014 YoungLee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
@interface ViewController : UIViewController<PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property NSNumber *latitudeInfo;
@property NSNumber *longitudeInfo;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

