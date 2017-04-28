//
//  BatteryLifeDebugEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "BatteryLifeDebugEvent.h"
#import "EventTypeEnum.h"

@implementation BatteryLifeDebugEvent

@synthesize batteryAfter;
@synthesize batteryBefore;
@synthesize endTime;
@synthesize startTime;

-(EventType)getEventType {
	return DEBUG_EVENT;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [batteryAfter release];
    [batteryBefore release];
    [endTime release];
    [startTime release];
	
    [super dealloc];
}


@end
