//
//  HTTPBatteryLifeDebugEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "HTTPBatteryLifeDebugEvent.h"
#import "DebugModeEnum.h"

@implementation HTTPBatteryLifeDebugEvent

@synthesize payloadSize;

-(DebugMode)getMode {
	return HTTP_BATTERY_LIFE;
}

- (int)getFieldCount {
	return 0;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    [payloadSize release];
	
    [super dealloc];
}

@end
