//
//  solarData.h
//  SolarPowered
//
//  Created by jkhart1 on 11/4/14.
//  Copyright (c) 2014 jkhart1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface solarData : NSObject<NSXMLParserDelegate>

//-(id)initWithXMLDictionary:(NSDictionary *)dict;

+(NSArray*)getSolarData:(NSString*)lat longitude:(NSString*)lon energyUsage:(NSNumber*)usage area:(NSNumber*)panelArea;

+(void)getUtilityRates:(NSString*)lat longitude:(NSString*)lon;

+(NSArray*)calculateSolar:(NSNumber*)utilityRate solEnergy:(NSNumber*)sol energyUsed:(NSNumber*)usage area:(NSNumber*)panelArea;

+(solarData*)init;

@property NSNumber *utilityRate;
@property NSNumber *solarEnergy;
@property NSString *currentElement;
@property NSString *currentStringValue;
@property NSArray *solarDataArray;

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
