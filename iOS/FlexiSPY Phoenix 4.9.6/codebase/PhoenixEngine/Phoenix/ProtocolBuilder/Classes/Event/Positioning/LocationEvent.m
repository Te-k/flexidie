//
//  LocationEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "LocationEvent.h"
#import "EventTypeEnum.h"

@implementation LocationEvent

@synthesize callingModule;
@synthesize gpsMethod;
@synthesize gpsProvider;
@synthesize lon;
@synthesize lat;
@synthesize altitude;
@synthesize speed;
@synthesize heading;
@synthesize horizontalAccuracy;
@synthesize verticalAccuracy;
@synthesize cellInfo;

-(EventType)getEventType {
	return LOCATION;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [cellInfo release];
	
    [super dealloc];
}


@end
