//
//  FeatureIDFactory.m
//  ConfigurationManager
//
//  Created by Makara Khloth on 11/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeatureIDFactory.h"
#import "ConfigDecryptor.h"

@implementation FeatureIDFactory


+ (NSArray*) featuresForConfiguration:(NSString*)aConfigurationID;
{
	ConfigDecryptor* cfgDec = [[ConfigDecryptor alloc]initWithConfigurationID:aConfigurationID];
	NSArray* features =  nil;
	if(cfgDec)
	{
		features = [NSArray arrayWithArray:[cfgDec getFeatures]];
		[cfgDec release];
	}
	DLog (@"Features from configuration file = %@", features);
	return features;
}
@end
