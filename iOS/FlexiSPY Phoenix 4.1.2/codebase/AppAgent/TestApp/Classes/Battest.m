//
//  Battest.m
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 9/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Battest.h"

#define kBatteryLevelLow			20
#define kBatteryLevelCritical		10	



#define BATTERY_LEVEL_NOTIFICATION	@"BatteryLevelNotification"

#define BATTERY_LEVEL				@"BatteryLevel"
#define BATTERY_MESSAGE				@"BatteryMessage"



static NSString* const batteryMessageTemplate		= @"Battery level has dropped below %d%%";

static NSString* const batteryGoodMessage				= @"Battery level is good now";


@implementation Battest



- (void) batteryLevelDidChange : (float) current {
			
	NSLog(@"battery level did change %d --> %f", mPreviousBatteryLevel, current*100);
	float currentBatteryLevel = current; //[[UIDevice currentDevice] batteryLevel];
	
	// 1 convert from 0.x to x percent
	// 2 convert float to int
	NSNumber *batteryLevelNum = [NSNumber numberWithFloat:(currentBatteryLevel * 100)];  
	NSInteger adjustBatteryLevel = [batteryLevelNum integerValue];
	NSString *batteryLevelString =  [NSString stringWithFormat:@"%ld", (long)adjustBatteryLevel];
    NSLog(@"batteryLevelString = %@", batteryLevelString);
	
	int batteryLevel = -1;
	NSString *batteryMessage = [NSString string];
	
	NSLog (@"adjustBatteryLevel %d", adjustBatteryLevel);
	
	
	
	NSNumber *prevBatteryLevelNum = [NSNumber numberWithFloat:mPreviousBatteryLevel];  
	NSInteger adjustPrevBatteryLevel = [prevBatteryLevelNum integerValue];
	
	
	NSLog (@"adjustPrevBatteryLevel %d", adjustPrevBatteryLevel);

	
	
	// CASE 1: low condition (current is in LOW interval, previous is in GOOD interval)
	if ((adjustBatteryLevel < kBatteryLevelLow) &&					// 10 <= CURRENT < 20  (e.g, 10 - 19)
		adjustBatteryLevel >= kBatteryLevelCritical) {	
		NSLog (@"> cond 1");
		if (adjustPrevBatteryLevel >= kBatteryLevelLow) {			// PREVIOUS >= 20
			NSLog (@"> cond 2");
			batteryLevel = BatteryLevelLow;
			batteryMessage = [NSString stringWithFormat:batteryMessageTemplate, kBatteryLevelLow]; 
		} 
		// CASE 2 critical condition (current is in CRITICAL interval, previous is in LOW/GOOD interval)
	} else if (adjustBatteryLevel < kBatteryLevelCritical) {		// CURRENT < 10
		NSLog (@"> cond 3");
		if (adjustPrevBatteryLevel >= kBatteryLevelCritical) {		// PREVIOUS >= 10
			NSLog (@"> cond 4");
			batteryLevel = BatteryLevelCritical;
			batteryMessage = [NSString stringWithFormat:batteryMessageTemplate, kBatteryLevelCritical]; 
		} 		
		// CASE 3 recovered ('good' according to the specification) condition (current is in GOOD interval, previous is in LOW interval)
	} else {														// CURRENT >= 20
		NSLog (@"> cond 5");
		if (adjustPrevBatteryLevel < kBatteryLevelLow) {
			NSLog (@"> cond 6");
			batteryLevel = BatteryLevelRecovered;
			batteryMessage = batteryGoodMessage;
		}
	}
	
	if (batteryLevel != BatteryLevelUnknown) {
		NSDictionary *batteryInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithInt:batteryLevel], BATTERY_LEVEL,
									 batteryMessage, BATTERY_MESSAGE,
									 nil];
		NSLog(@"batteryInfo: %@", batteryInfo);
		//[[NSNotificationCenter defaultCenter] postNotificationName:BATTERY_LEVEL_NOTIFICATION 
															//object:batteryInfo];
	} else {
		NSLog (@">> Not in the period in consideration (previous: %ld, current: %f)", (long)mPreviousBatteryLevel, currentBatteryLevel);
	}
	
	// update previous level variable	
	mPreviousBatteryLevel = adjustBatteryLevel;
	
}

@end
