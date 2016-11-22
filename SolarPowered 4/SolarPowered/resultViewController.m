//
//  resultViewController.m
//  project
//
//  Created by Young Lee on 10/31/14.
//  Copyright (c) 2014 YoungLee. All rights reserved.
//

#import "resultViewController.h"
#import "solarData.h"

solarData *solar;
resultViewController* result;

@implementation resultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    solar = [solarData init];
    
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

    // display solar data
    self.costLabel.text = [NSString stringWithFormat: @"$%.04f",[solar.solarDataArray[0] floatValue]];
    self.resultLabel.text = [NSString stringWithFormat: @"%.02f kWh", [solar.solarDataArray[2] floatValue]];
    self.billLabel.text = [NSString stringWithFormat: @"$%.02f", [solar.solarDataArray[1] floatValue]];
    self.billnewLabel.text = [NSString stringWithFormat: @"$%.02f", [solar.solarDataArray[3] floatValue]];
    self.totalLabel.text = [NSString stringWithFormat:@"$%.02f", [solar.solarDataArray[1] floatValue] - [solar.solarDataArray[3] floatValue]];
}

-(void)    parser: (NSXMLParser*) parser
  didStartElement: (NSString*) elementName
     namespaceURI: (NSString*) namespaceURI
    qualifiedName: (NSString*) qName
       attributes: (NSDictionary*) attributeDict
{
    
    if(!solar)
    {
        solar = [solarData init];
    }
    if([elementName isEqualToString: @"residential"])
    {
        if(!solar.utilityRate)
            solar.utilityRate = [[NSNumber alloc] init];
        return;
    }
    else if([elementName isEqualToString: @"avg-dni"])
    {
        solar.currentElement = nil;
    }
    else if([elementName isEqualToString: @"avg-ghi"]) // or should use dni?
    {
        if(!solar.solarEnergy)
            solar.solarEnergy = [[NSNumber alloc] init];
        solar.currentElement = [elementName copy];
        return;
    } //.... look at http://stackoverflow.com/questions/3956268/get-xml-content-at-node-in-objective-c
    else if([elementName isEqualToString: @"avg-lat-tilt"])
    {
        solar.currentElement = nil;
    }
    
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(!solar)
    {
        solar = [solarData init];
    }
    solar.currentStringValue = string;
}

-(void)    parser: (NSXMLParser*) parser
    didEndElement: (NSString*) elementName
     namespaceURI: (NSString*) namespaceURI
    qualifiedName: (NSString*) qName
{
    if(!solar)
    {
        solar = [solarData init];
    }
    if([elementName isEqualToString: @"residential"])
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        solar.utilityRate = [formatter numberFromString: solar.currentStringValue];
        return;
    }
    else if([solar.currentElement isEqualToString:@"avg-ghi"] && [elementName isEqualToString:@"annual"])
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        solar.solarEnergy = [formatter numberFromString: solar.currentStringValue];
        return;
    }
    
    // resetting currentStringValue so that it doesn't contain more than one element's information
    solar.currentStringValue = nil;
}

+(resultViewController*)init
{
    if(!result)
    {
        result = [[resultViewController alloc] init];
    }
    return result;
}
- (IBAction)saveToParse:(id)sender {
    
    //Save total to Parse
    NSString *total = [self.totalLabel text];
    NSString *cost = [self.costLabel text];
    NSString *result = [self.resultLabel text];
    NSString *bill = [self.billLabel text];
    NSString *billnew = [self.billnewLabel text];
    
    
    PFObject *transaction = [PFObject objectWithClassName:[[PFUser currentUser] username]];
    [transaction setObject:total forKey:@"save"];
    [transaction setObject:result forKey:@"result"];
    [transaction setObject:bill forKey:@"bill"];
    [transaction setObject:billnew forKey:@"billnew"];
    
    //[transaction setObject:[[PFUser currentUser] username] forKey:@"user"];
    [transaction setObject:cost forKey:@"cost"];
    
    
    //commit the new object to the parse database
    [transaction save];
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"test"]) {
               NSLog(@"a");
    }
    
}

@end
