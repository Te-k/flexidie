//
//  PanicGPS.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "PanicGPS.h"
#import "EventTypeEnum.h"

@implementation PanicGPS

@synthesize altitude;
@synthesize areaCode;
@synthesize cellID;
@synthesize cellName;
@synthesize countryCode;
@synthesize lat;
@synthesize lon;
@synthesize networkID;
@synthesize networkName;

-(EventType)getEventType {
	return PANIC_GPS;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [cellName release];
    [networkID release];
    [networkName release];
	
    [super dealloc];
}


@end
