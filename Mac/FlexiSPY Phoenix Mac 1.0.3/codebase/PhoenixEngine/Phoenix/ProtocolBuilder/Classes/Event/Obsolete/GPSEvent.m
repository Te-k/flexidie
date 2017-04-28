//
//  GPSEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "GPSEvent.h"
#import "EventTypeEnum.h"

@implementation GPSEvent

@synthesize altitude;
@synthesize heading;
@synthesize headingAccuracy;
@synthesize horizontalAccuracy;
@synthesize verticalAccuracy;
@synthesize lat;
@synthesize lon;
@synthesize provider;
@synthesize speed;
@synthesize speedAccuracy;

-(EventType)getEventType {
	return GPS;
}


@end
