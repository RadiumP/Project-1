//
//  solarData.m
//  project
//
//  Created by jkhart1 on 11/4/14.
//  Copyright (c) 2014 YoungLee. All rights reserved.
//

#import "solarData.h"
#import "resultViewController.h"
@import Foundation;

@implementation solarData

double METERS_PER_FOOT = 0.3048;

NSString *solarAPIKey = @"m8WM4u44zrJJ3jo3vQgIai62kKblUn7fXRKqXbqE";
NSString *solarBaseURL = @"http://developer.nrel.gov/api/solar/solar_resource/v1.xml?api_key=";
NSString *utilityAPIKey = @"IFx1rCYh1xpaosGcGpZTc6yunpFFaohJk3Ydl6Qr";
NSString *utilityBaseURL = @"http://developer.nrel.gov/api/utility_rates/v3.xml?api_key=";
solarData *solarSelf;
resultViewController* result;


+(void)getUtilityRates:(NSString*)lat longitude:(NSString*)lon
{
    if(!result)
    {
        result = [resultViewController init];
    }
    
    if(!solarSelf)
    {
        [self init];
    }
    
    BOOL success = NO;
    
    // Build API URL
    NSString *utilityURL = [NSString stringWithFormat:@"%@%@%@%@%@%@", utilityBaseURL, utilityAPIKey, @"&lat=", lat, @"&lon=", lon];
    
    // Make API Call
    NSData *utilityQuery = [NSData dataWithContentsOfURL:[NSURL URLWithString:utilityURL]];
    
    if(utilityQuery == nil)
    {
        // NSLog, then display error in main view
    }
    
    // Parse for data
    NSXMLParser *utilityParser = [[NSXMLParser alloc] initWithData:utilityQuery];
    
    [utilityParser setDelegate:result];
    
    [utilityParser setShouldProcessNamespaces:NO];
    [utilityParser setShouldReportNamespacePrefixes:NO];
    [utilityParser setShouldResolveExternalEntities:NO];
    
    success = [utilityParser parse];
    
    return;// solarSelf.utilityRate;
}


+(NSArray*)getSolarData:(NSString*)lat longitude:(NSString*)lon energyUsage:(NSNumber*)usage area:(NSNumber*)panelArea
{
    if(!result)
    {
        result = [resultViewController init];
    }
    
    if(!solarSelf)
    {
        [self init];
    }
    
    //NSArray *solarDataArray;
    
    NSString *solarURL = [NSString stringWithFormat:@"%@%@%@%@%@%@", solarBaseURL, solarAPIKey, @"&lat=", lat, @"&lon=", lon];
    
    // Get Utility Rates
    //NSNumber *utlityRate =
    [self getUtilityRates:lat longitude:lon];
    
    // Make API Call
    NSData *solarQuery = [NSData dataWithContentsOfURL:[NSURL URLWithString:solarURL]];
    
    if(solarQuery == nil)
    {
        // error handling
    }
    
    // Parse for data
    NSXMLParser *solarParser = [[NSXMLParser alloc] initWithData:solarQuery];
    
    [solarParser setDelegate:result];
    
    [solarParser parse];
    
    // Pass to calculation Function
    solarSelf.solarDataArray = [self calculateSolar:solarSelf.utilityRate solEnergy: solarSelf.solarEnergy energyUsed:usage
        area:panelArea];
    
    
    // Put all relevant info in solarDataArray
    
    return solarSelf.solarDataArray;
}

+(NSArray*)calculateSolar:(NSNumber*)utilityRate solEnergy:(NSNumber*)sol energyUsed:(NSNumber*)usage area:(NSNumber*)panelArea
{
    if(!solarSelf)
    {
        [self init];
    }
    
    NSArray *calculatedData;
    
    NSNumber *solarGenerated;
        // here we need a formula to get this information
            // Energy = Area (of solar panelling in meter sq) * r (solar panel yield % (we will use 15%, until we develop a better understanding of how to calculate this) * H (annual average solar radiation) * PR (performance ratio, 0.75 default)
    
    // 100 sq ft ~= 9.29 sq meters
    // 400 sq ft ~= 37.16
    
    panelArea = [NSNumber numberWithDouble: METERS_PER_FOOT * panelArea.doubleValue];
    
    solarGenerated = [NSNumber numberWithDouble:panelArea.doubleValue * 15 * sol.doubleValue * 0.75];
    
    // cost of energy in area
        //[0] will be utilityRate
    NSNumber *val1 = utilityRate;
    // estimated monthly bill
        //[1] will be utilityRate*energyUsed
    NSNumber *val2 = [NSNumber numberWithDouble:utilityRate.doubleValue * usage.doubleValue];
    // energy savings
        //[2] will store maxval(0, (energyUsed - solEnergy))  // and in results, display it in relation to % of old total, or just display both it and old total
    NSNumber *val3 = [NSNumber numberWithDouble:usage.doubleValue - (solarGenerated.doubleValue/12)];
    // new estimated bill
        //[3] will store [2]*utilityRate
    NSNumber *val4 = [NSNumber numberWithDouble:val3.doubleValue*utilityRate.doubleValue];
    
    calculatedData = [NSArray arrayWithObjects:val1,val2,val3,val4,nil];
    
    return calculatedData;
}

+(solarData*)init
{
    if(!solarSelf)
    {
        solarSelf = [[solarData alloc] init];
    }
    return solarSelf;
}



@end




/*-------------------------------------------------------------------------------------------------------------------------------------------------
 
 Solar Energy:
 
	info URL:		http://www.cleanpower.com/products/solaranywhere/solaranywhere-api/
	API key:		m8WM4u44zrJJ3jo3vQgIai62kKblUn7fXRKqXbqE
	example call:	http://developer.nrel.gov/api/solar/solar_resource/v1.xml?api_key=m8WM4u44zrJJ3jo3vQgIai62kKblUn7fXRKqXbqE&lat=40&lon=-105
 
 
 NREL Utility Rates:
 
	info URL: 		http://developer.nrel.gov/docs/electricity/utility-rates-v3/#examples
	API key:  		IFx1rCYh1xpaosGcGpZTc6yunpFFaohJk3Ydl6Qr
	example call:	http://developer.nrel.gov/api/utility_rates/v3.xml?api_key=DEMO_KEY&lat=35.45&lon=-82.98
 
 -------------------------------------------------------------------------------------------------------------------------------------------------*/