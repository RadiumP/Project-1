//
//  ViewController.m
//  project
//
//  Created by Young Lee on 10/30/14.
//  Copyright (c) 2014 YoungLee. All rights reserved.
//

#import "ViewController.h"
#import "resultViewController.h"
#import "solarData.h"
#import "UserInputViewController.h"
@import CoreLocation;

double METERS_PER_MILE = 1609.344;
NSArray *solar;

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *longitude;
@property (weak, nonatomic) IBOutlet UITextField *latTextField;
@property (weak, nonatomic) IBOutlet UITextField *longTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipTextField;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *bestEffortAtLocation;
@property (weak, nonatomic) IBOutlet UILabel *detectLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property BOOL needLocation;
@property BOOL getZip;
- (IBAction) detectButton:(id)sender;
- (IBAction) checkResult:(id)sender;
- (IBAction) logout:(id)sender;

@end


@implementation ViewController

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.zipTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.latTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [self.longTextField setKeyboardType:UIKeyboardTypeNumberPad];
    if (![PFUser currentUser])      // no user logged in
    {
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];      // create login controller
        [logInViewController setDelegate:self];
        
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];   // create signup controller
        [signUpViewController setDelegate:self];
        
        [logInViewController setSignUpController:signUpViewController];
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    
    UIImage *bgImage = [UIImage imageNamed: @"Background1.png"];       // load image
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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    [self.latTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingDidEnd];
    [self.longTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingDidEnd];
    [self.zipTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingDidEnd];
    
    if (self.latitudeInfo == nil)
        self.latitudeInfo = [NSNumber numberWithFloat:0];
    if (self.longitudeInfo == nil)
        self.longitudeInfo = [NSNumber numberWithFloat:0];
    
    self.detectLabel.text = @"Click below to go to your location.";
}

- (IBAction) detectButton:(id)sender
{
    // DEFAULT COORDINATES
    // set your iOS Simulator location to this (Debug > Location > Custom Location)
    if (self.latitudeInfo == nil)
        self.latitudeInfo = [NSNumber numberWithFloat:33.42373];
    if (self.longitudeInfo == nil)
        self.longitudeInfo = [NSNumber numberWithFloat:-111.93945];
    
    self.detectLabel.text = @"Automatically detecting coordinates...";
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];       // request user's permission to use location
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];           // get user's location
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.detectLabel.text = @"Your location has been detected!";
    
    self.latitudeInfo = [NSNumber numberWithFloat:newLocation.coordinate.latitude];       // update latitutde
    self.longitudeInfo = [NSNumber numberWithFloat:newLocation.coordinate.longitude];     // update longitude
    self.latTextField.text = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    self.longTextField.text = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
        
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@", self.latTextField.text, self.longTextField.text]];      // update zipcode
    self.getZip = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection start];      // start manually to remove unused variable warning
        
    [self updateMap:newLocation];       // update map to display new location
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError*)error
{
    // if location failed to update, use these default values
    CLLocation *newloc = [[CLLocation alloc] initWithLatitude:33.42373 longitude:-111.93945];
    [self locationManager:self.locationManager didUpdateToLocation:newloc fromLocation:newloc];
}

- (void) updateMap:(CLLocation *)newLocation
{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = newLocation.coordinate.latitude;        // set latitude coordinate
    zoomLocation.longitude = newLocation.coordinate.longitude;       // set longitude coordinate
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5 * METERS_PER_MILE, 0.5 * METERS_PER_MILE);
    
    [self.mapView setRegion:viewRegion animated:YES];       // set map region
}

- (IBAction) checkResult:(id)sender
{
    // NSString *zip = self.zipcodeTextfield.text;
    // NSString *api_test = [NSString stringWithFormat: @"https://zipcodedistanceapi.redline13.com/rest/if2guXxR0Xb353nJlLzMrdeuKcAN7k7qz9G46dV6a7agayZwkzjMNxgyKRmRbthL/info.json/%@/degrees", zip];
    
    if ([self.latTextField.text isEqualToString:@""] || [self.longTextField.text isEqualToString:@""])
        self.detectLabel.text = @"Please enter a valid location.";
    //else
      //  [self getData];
}

- (void) getData  //API
{
    NSString *lat = [NSString stringWithFormat:@"%@",self.latitudeInfo];
    NSString *lon = [NSString stringWithFormat:@"%@",self.longitudeInfo];
    // also convert string version of these into numbers for properties in the .h file
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.latitudeInfo = [formatter numberFromString: lat];
    self.longitudeInfo = [formatter numberFromString: lon];
    
    //solar = [solarData getSolarData:lat longitude:lon energyUsage: [NSNumber numberWithInt:940]]; // replace 250 with real input
    
    // then extract pertinent data from solar:
    // cost of energy in area
    // estimated monthly bill
    // energy savings
    // new estimated bill
    
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([self.latTextField.text isEqualToString:@""] || [self.longTextField.text isEqualToString:@""])
        return NO;
    return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
        UserInputViewController *destViewController = segue.destinationViewController;
        destViewController.latitude = self.latitudeInfo;
        destViewController.longitude = self.longitudeInfo;
        destViewController.zipCode = self.zipTextField.text;
    
}

- (void) didRecognizeTapGesture:(UITapGestureRecognizer*)gesture
{
    [self.latTextField resignFirstResponder];
    [self.longTextField resignFirstResponder];
    [self.zipTextField resignFirstResponder];
}

- (void) textFieldDidChange:(UITextField *)theTextField
{
    self.detectLabel.text = @"Click below to go to your location.";
        
    NSURL *url;
    if (theTextField == self.latTextField || theTextField == self.longTextField)
    {
        // get zipcode corresponding to lat/long
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@", self.latTextField.text, self.longTextField.text]];
        self.getZip = YES;
    }
    else
    {
        // get lat/long corresponding to zipcode
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@", self.zipTextField.text]];
        self.getZip = NO;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection start];      // start manually to remove unused variable warning
}


#pragma mark - NSURLConnection

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    self.latlongDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:Nil];    // store JSON data in dictionary
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([[self.latlongDict valueForKey:@"status"] isEqualToString:@"OK"])       // if JSON loaded successfully
    {
        if (self.getZip == YES)
        {
            NSUInteger count = [[[[self.latlongDict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"] count];
            for (int i = 0; i < count; i++)
            {
                if ([[[[[[[self.latlongDict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"] objectAtIndex:i] objectForKey:@"types"]   objectAtIndex:0] isEqualToString:@"postal_code"])
                {
                    self.zipTextField.text = [[[[[self.latlongDict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"] objectAtIndex:i] valueForKey:@"long_name"];
                    break;
                }
            }
        }
        else
        {
            self.latTextField.text = [[[[[[self.latlongDict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] stringValue];
            self.longTextField.text = [[[[[[self.latlongDict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] stringValue];
        }
    }
    
    if ([self.latTextField.text floatValue] >= -85 && [self.latTextField.text floatValue] <= 85)
        self.latitudeInfo = [NSNumber numberWithFloat:[self.latTextField.text floatValue]];      // update latitude
    else
        self.latTextField.text = [self.latitudeInfo stringValue];
    if ([self.longTextField.text floatValue] >= -180 && [self.longTextField.text floatValue] <= 180)
        self.longitudeInfo = [NSNumber numberWithFloat:[self.longTextField.text floatValue]];    // update longitude
    else
        self.longTextField.text = [self.longitudeInfo stringValue];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = (CLLocationDegrees)[self.latitudeInfo doubleValue];        // set latitude coordinate
    zoomLocation.longitude = (CLLocationDegrees)[self.longitudeInfo doubleValue];       // set longitude coordinate
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5 * METERS_PER_MILE, 0.5 * METERS_PER_MILE);
    [self.mapView setRegion:viewRegion animated:YES];       // update map
}


#pragma mark - Parse

- (BOOL) logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    if (username && password && username.length != 0 && password.length != 0)
        return YES;     // begin login process
    
    // not all fields are completed
    [[[UIAlertView alloc] initWithTitle:@"Missing information!" message:@"Please fill out all of the required fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    return NO;
}

- (void) logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    // user logged in successfully
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    // login attempt has failed
    NSLog(@"Failed to log in...");
}

- (void) logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    // login screen is dismissed
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info
{
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info)
    {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0)
        {
            informationComplete = NO;    // check for completion
            break;
        }
    }

    if (!informationComplete)
        [[[UIAlertView alloc] initWithTitle:@"Missing information!" message:@"Please fill out all of the required fields." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];       // one or more fields not completed
    
    return informationComplete;
}

- (void) signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    // PFUser is signed up
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error
{
    // signup attempt has failed
    NSLog(@"Failed to sign up...");
}

- (void) signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController
{
    // signup cancelled
    NSLog(@"User dismissed the signUpViewController");
}

- (IBAction)logout:(id)sender
{
    [PFUser logOut];        // logout PFUser
    [self viewDidAppear:YES];
}






@end
