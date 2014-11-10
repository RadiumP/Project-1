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
@import CoreLocation;

@interface ViewController ()<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *longitude;
- (IBAction)checkResult:(id)sender;

- (IBAction)logout:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *energyTextfield;
@property CLLocationManager *locationManager;
@end

NSArray *solar;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated {
    
    
    
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser]) { // No user logged in
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
        [super viewDidAppear:animated];
        
       
        
    }
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissModalViewControllerAnimated:YES]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}


-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    self.latitudeInfo = [NSNumber numberWithFloat:newLocation.coordinate.latitude];
    self.longitudeInfo = [NSNumber numberWithFloat:newLocation.coordinate.longitude];
    self.latitude.text =[ NSString stringWithFormat:@"%f",newLocation.coordinate.latitude ];
    self.longitude.text =[ NSString stringWithFormat:@"%f",newLocation.coordinate.longitude ];//longitude
}


- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self viewDidAppear:YES];
}

- (IBAction)checkResult:(id)sender {
    
   // NSString *zip = self.zipcodeTextfield.text;
    
   // NSString *api_test = [NSString stringWithFormat: @"https://zipcodedistanceapi.redline13.com/rest/if2guXxR0Xb353nJlLzMrdeuKcAN7k7qz9G46dV6a7agayZwkzjMNxgyKRmRbthL/info.json/%@/degrees", zip];
    
    [self getData];
    
}

-(void)getData  //API

{
    NSNumber*avgEnergy;
    
    
  

    NSString *lat = [NSString stringWithFormat:@"%@",self.latitudeInfo];

    //NSString *lon = [NSString stringWithFormat:@"%@",[latlon objectForKey:@"lng"]];
    NSString *lon = [NSString stringWithFormat:@"%@",self.longitudeInfo];
    // also convert string version of these into numbers for properties in the .h file
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.latitudeInfo = [formatter numberFromString: lat];
    self.longitudeInfo = [formatter numberFromString: lon];
    
    solar = [solarData getSolarData:lat longitude:lon energyUsage: [NSNumber numberWithInt:940]]; // replace 250 with real input
    
    // then extract pertinent data from solar:
        // cost of energy in area
        // estimated monthly bill
        // energy savings
        // new estimated bill
    
}

//

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"result"])
    {
        resultViewController *destViewController = segue.destinationViewController;
        destViewController.latitude = self.latitudeInfo;
        destViewController.longitude = self.longitudeInfo;
       
    }
}


@end
