//
//  BatteryMonitor.m
//  AppAgent
//
//  Created by Benjawan Tanarattanakorn on 9/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "BatteryMonitor.h"
#import <UIKit/UIKit.h>


#define kBatteryLevelLow			20
#define kBatteryLevelCritical		10	


static NSString* const batteryMessageTemplate			= @"Battery level has dropped below %d%%";
static NSString* const batteryGoodMessage				= @"Battery level is good now";


@implementation BatteryMonitor

- (id) init {
	self = [super init];
	if (self != nil) {
		mIsListening = FALSE;
	}
	return self;
}

/**
 - Method name:						startMonotorBatteryLevelNotification
 - Purpose:							This method aims to start monitoring of battery level notification
 - Argument list and description:	None
 - Return type and description:		None
 */
- (void) startMonotorBatteryLevelNotification {
	if (!mIsListening) {
		mIsListening = TRUE;
		DLog(@"BatteryMonitor --> startMonotorBatteryLevelNotification: main thread ? %d", [NSThread isMainThread]);				
		
		[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
		
		NSNumber *batteryLevelNum = [NSNumber numberWithFloat:([[UIDevice currentDevice] batteryLevel] * 100)];  
		mPreviousBatteryLevel = [batteryLevelNum integerValue];
		
		DLog(@">>> Start monitor battery with %ld percent", (long)mPreviousBatteryLevel);
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(batteryLevelDidChange:)
													 name:UIDeviceBatteryLevelDidChangeNotification
												   object:nil];

	} 
}

/**
 - Method name:						stopMonotorBatteryLevelNotification
 - Purpose:							This method aims to stop monitoring of battery level notification
 - Argument list and description:	None
 - Return type and description:		None
 */
- (void) stopMonotorBatteryLevelNotification {
	if (mIsListening) {
		DLog(@">>> Stop monitor battery with %f percent", (double)mPreviousBatteryLevel);

		[[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:UIDeviceBatteryLevelDidChangeNotification
													  object:nil];	
	}
}

// callback of battery monitoring
// this methods will be invoked after start battery monitoring (by calling the function startMonotorBatteryLevelNotification)
- (void) batteryLevelDidChange: (NSNotification *) notification {
	DLog(@"battery level did change %ld --> %f", (long)mPreviousBatteryLevel, [[UIDevice currentDevice] batteryLevel] * 100);
	float currentBatteryLevel = [[UIDevice currentDevice] batteryLevel];
	
	// 1 convert from 0.x to y percent (e.g., 0.1 --> 0.1 x 100 = 10 %)
	// 2 convert float to int
	NSNumber *batteryLevelNum = [NSNumber numberWithFloat:(currentBatteryLevel * 100)];  
	NSInteger adjustBatteryLevel = [batteryLevelNum integerValue];
	
	BatteryNotificationLevel batteryLevel = BatteryLevelUnknown;
	NSString *batteryMessage = [NSString string];
			
	NSNumber *prevBatteryLevelNum = [NSNumber numberWithFloat:mPreviousBatteryLevel];  
	NSInteger adjustPrevBatteryLevel = [prevBatteryLevelNum integerValue];
	DLog (@"adjustBatteryLevel %ld", (long)adjustBatteryLevel)
	DLog (@"adjustPrevBatteryLevel %ld", (long)adjustPrevBatteryLevel)
	
	/******** Low condition ********
	 GOOD (20 %)		LOW (15 %)
	 ====			=  =
	 ====	-->		====
	 ====			====

	*******************************/
	// CASE 1: low condition (current is in LOW interval, previous is in GOOD interval)
	if ((adjustBatteryLevel < kBatteryLevelLow) &&					// 10 <= CURRENT < 20  (e.g, 10 - 19)
		adjustBatteryLevel >= kBatteryLevelCritical) {	
		DLog (@"> cond 1")
		if (adjustPrevBatteryLevel >= kBatteryLevelLow) {			// PREVIOUS >= 20
			DLog (@"> cond 2")
			batteryLevel = BatteryLevelLow;
			batteryMessage = [NSString stringWithFormat:batteryMessageTemplate, kBatteryLevelLow]; 
		} 
	 
	 /**** Critical condition *****
	  LOW (10 %)		CRITICAL (5 %)
	  =  =			=  = 
	  ====	-->		=  =
	  ====			====
	  
	*****************************/
	// CASE 2 critical condition (current is in CRITICAL interval, previous is in LOW/GOOD interval)
	} else if (adjustBatteryLevel < kBatteryLevelCritical) {		// CURRENT < 10
		DLog (@"> cond 3")
		if (adjustPrevBatteryLevel >= kBatteryLevelCritical) {		// PREVIOUS >= 10
			DLog (@"> cond 4")
			batteryLevel = BatteryLevelCritical;
			batteryMessage = [NSString stringWithFormat:batteryMessageTemplate, kBatteryLevelCritical]; 
		} 		
		
	/**** Recover condition *****
	 LOW (15 %)		GOOD (20 %)
	 =  =			====
	 ====	-->		====
	 ====			====
	 
	 *****************************/
	// CASE 3 recovered ('good' according to the specification) condition (current is in GOOD interval, previous is in LOW interval)
	} else {														// CURRENT >= 20
		DLog (@"> cond 5")
		if (adjustPrevBatteryLevel < kBatteryLevelLow) {			// PREVIOUS < 20
			DLog (@"> cond 6")
			batteryLevel = BatteryLevelRecovered;
			batteryMessage = batteryGoodMessage;
		}
	}
	
	// -- battery is in the interesting intervals													 
	if (batteryLevel != BatteryLevelUnknown) {
		NSDictionary *batteryInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithInt:batteryLevel], BATTERY_LEVEL,
									 batteryMessage, BATTERY_MESSAGE,
									nil];

		[[NSNotificationCenter defaultCenter] postNotificationName:BATTERY_LEVEL_NOTIFICATION 
															object:batteryInfo];
	} else {
		DLog (@">> Not in the period in consideration (previous: %ld, current: %ld)", (long)mPreviousBatteryLevel, (long)currentBatteryLevel)
	}
	
	// update previous level variable	
	mPreviousBatteryLevel = adjustBatteryLevel;
}

- (void) dealloc {
	[self stopMonotorBatteryLevelNotification];
	[super dealloc];
}


@end
