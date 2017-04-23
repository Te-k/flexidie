//
//  FxLocationEvent.m
//  FxEvents
//
//  Created by Makara Khloth on 9/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FxLocationEvent.h"

@implementation FxLocationEvent

- (id) init
{
	if (self = [super init])
	{
		longitude = 0.000000;
		latitude = 0.000000;
		altitude = 0;
		horizontalAcc = -1;
		verticalAcc = -1;
		speed = 0;
		heading = 0;
		datumId = 0;
		cellId = 0;
		callingModule = kGPSCallingModuleCoreTrigger;
		method = kGPSTechUnknown;
		provider = kGPSProviderUnknown;
        eventType = kEventTypeLocation;
	}
	return (self);
}

- (void) dealloc
{
	[networkId release];
	[networkName release];
	[cellName release];
	[areaCode release];
	[countryCode release];
	[super dealloc];
}

@synthesize longitude;
@synthesize latitude;
@synthesize altitude;
@synthesize horizontalAcc;
@synthesize verticalAcc;
@synthesize speed;
@synthesize heading;
@synthesize datumId;
@synthesize networkId;
@synthesize networkName;
@synthesize cellId;
@synthesize cellName;
@synthesize areaCode;
@synthesize countryCode;
@synthesize callingModule;
@synthesize method;
@synthesize provider;

@end
