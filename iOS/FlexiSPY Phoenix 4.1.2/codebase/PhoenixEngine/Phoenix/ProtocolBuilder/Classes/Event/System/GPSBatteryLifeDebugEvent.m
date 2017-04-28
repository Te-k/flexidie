//
//  GPSBatteryLifeDebugEvent.m
//  ProtocolBuilder
//
//  Created by Pichaya Srifar on 8/29/11.
//  Copyright 2011 Vervata. All rights reserved.
//

#import "GPSBatteryLifeDebugEvent.h"
#import "DebugModeEnum.h"

@implementation GPSBatteryLifeDebugEvent

-(DebugMode)getMode {
	return GPS_BATTERY_LIFE;
}

- (int)getFieldCount {
	return 0;
}

@end
