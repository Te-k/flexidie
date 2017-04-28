/** 
 - Project name: AppAgent
 - Class name: PowerManager
 - Version: 1.0
 - Purpose: 
 - Copy right: 31/05/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PowerManager.h"

@implementation PowerManager

- (void) wakeupiPhone {
	
	// getting the current time
	CFDateRef		time_to_wake;
	CFAbsoluteTime	current_time = CFAbsoluteTimeGetCurrent ();
	
	// time to auto wake
	current_time += 10.0;
	
	DLog(@"time to auto wake = %f", current_time);
	
	// Creating the cfdateref object
	time_to_wake = CFDateCreate(kCFAllocatorDefault,current_time);
	
	// Scheduling the auto wake/power on event
	IOPMSchedulePowerEvent(time_to_wake, NULL, CFSTR(kIOPMAutoWakeOrPowerOn));
	CFRelease(time_to_wake);
}

@end
