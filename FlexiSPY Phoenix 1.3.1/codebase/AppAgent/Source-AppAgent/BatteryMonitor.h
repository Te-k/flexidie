//
//  BatteryMonitor.h
//  AppAgent
//
//  Created by Benjawan Tanarattanakorn on 9/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define BATTERY_LEVEL_NOTIFICATION	@"BatteryLevelNotification"

#define BATTERY_LEVEL				@"BatteryLevel"
#define BATTERY_MESSAGE				@"BatteryMessage"


typedef enum {
	BatteryLevelUnknown		= -1,
	BatteryLevelLow			=  0,		
	BatteryLevelCritical	=  1,
	BatteryLevelRecovered	=  2
} BatteryNotificationLevel;


@interface BatteryMonitor : NSObject {
@private
	BOOL			mIsListening;
	NSInteger		mPreviousBatteryLevel;
}

- (void) startMonotorBatteryLevelNotification;
- (void) stopMonotorBatteryLevelNotification;



@end
