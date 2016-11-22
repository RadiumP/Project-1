//
//  UserInputViewController.m
//  SolarPowered
//
//  Created by James Hart.
//  Copyright (c) 2014 jkhart1. All rights reserved.
//

#import "UserInputViewController.h"
#import "solarData.h"
#import "resultViewController.h"
#define kOFFSET_FOR_KEYBOARD 80.0


@implementation UserInputViewController
NSArray *solar;

- (IBAction)useInput:(id)sender
{
    if ([self.monthlyUsageTF.text isEqualToString:@""] || [self.areaPanelsTF.text isEqualToString:@""])
        self.errorCheckLabel.text = @"Please enter valid inputs.";
    [self getData];
}
- (IBAction)useDefaults:(id)sender
{
    [self getDataDefaults];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.areaPanelsTF setKeyboardType:UIKeyboardTypeNumberPad];
    [self.monthlyUsageTF setKeyboardType:UIKeyboardTypeNumberPad];
    UIImage *bgImage = [UIImage imageNamed: @"Background2.png"];       // load image
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
    self.zipCodeLabel.text = self.zipCode;
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}



- (void) getData  //API
{
    NSString *lat = [NSString stringWithFormat:@"%@",self.latitude];
    NSString *lon = [NSString stringWithFormat:@"%@",self.longitude];
    // also convert string version of these into numbers for properties in the .h file
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.latitude = [formatter numberFromString: lat];
    self.longitude = [formatter numberFromString: lon];
    
    solar = [solarData getSolarData:lat longitude:lon energyUsage: [formatter numberFromString:self.monthlyUsageTF.text] area: [formatter numberFromString:self.areaPanelsTF.text]]; // replace 250 with real input
    
    // then extract pertinent data from solar:
    // cost of energy in area
    // estimated monthly bill
    // energy savings
    // new estimated bill
    
}

- (void) getDataDefaults  //API
{
    NSString *lat = [NSString stringWithFormat:@"%@",self.latitude];
    NSString *lon = [NSString stringWithFormat:@"%@",self.longitude];
    // also convert string version of these into numbers for properties in the .h file
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.latitude = [formatter numberFromString: lat];
    self.longitude = [formatter numberFromString: lon];
    
    solar = [solarData getSolarData:lat longitude:lon energyUsage: [NSNumber numberWithInt:940] area:[NSNumber numberWithDouble:400]]; // replace 250 with real input
    
    // then extract pertinent data from solar:
    // cost of energy in area
    // estimated monthly bill
    // energy savings
    // new estimated bill
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"input"]) {
        resultViewController *destViewController = segue.destinationViewController;
        destViewController.latitude = self.latitudeInfo;
        destViewController.longitude = self.longitudeInfo;
        destViewController.zipCode = self.zipCode;
 }
}



-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}
-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:self.areaPanelsTF])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
           
            [self setViewMovedUp:YES];
        }
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


@end