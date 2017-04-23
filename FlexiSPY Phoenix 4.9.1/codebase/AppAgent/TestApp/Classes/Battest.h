//
//  Battest.h
//  TestApp
//
//  Created by Benjawan Tanarattanakorn on 9/12/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	BatteryLevelUnknown		= -1,
	BatteryLevelLow			=  0,		
	BatteryLevelCritical	=  1,
	BatteryLevelRecovered	=  2
} BatteryNotificationLevel;


@interface Battest : NSObject {
@private
	BOOL			mIsListening;
	NSInteger		mPreviousBatteryLevel;
}


- (void) batteryLevelDidChange : (float) current;
@end
