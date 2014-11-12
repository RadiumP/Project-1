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

- (void)viewDidLoad {
    [super viewDidLoad];

    solar = [solarData init];


    // Do any additional setup after loading the view, typically from a nib.
    self.costLabel.text = [NSString stringWithFormat: @"%@",solar.solarDataArray[0]];
   self.resultLabel.text = [NSString stringWithFormat: @"%@",solar.solarDataArray[2]];
    self.billLabel.text = [NSString stringWithFormat: @"%@",solar.solarDataArray[1]];
     self.billnewLabel.text = [NSString stringWithFormat: @"%@",solar.solarDataArray[3]];
    double bill = [self.billLabel.text doubleValue];
    double newbill = [self.billnewLabel.text doubleValue];
    double save = bill - newbill;
    self.totalLabel.text = [NSString stringWithFormat:@"%3f",save];
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
    PFObject *transaction = [PFObject objectWithClassName:@"UserData"];
    [transaction setObject:total forKey:@"amount"];
    [transaction setObject:[[PFUser currentUser] username] forKey:@"user"];
    //commit the new object to the parse database
    [transaction save];
}

@end
