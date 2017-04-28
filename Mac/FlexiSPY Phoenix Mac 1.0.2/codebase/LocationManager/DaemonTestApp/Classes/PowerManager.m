//
//  PowerManager.m
//  Insomania
//
//  Created by admin on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PowerManager.h"

@implementation PowerManager

- (void)wakeupiPhone {
	
	//getting the current time
	CFDateRef time_to_wake;
	CFAbsoluteTime current_time=CFAbsoluteTimeGetCurrent ();
	
	//time to auto wake
	current_time+=10.0;
	
	printf("current time=%f",current_time);
	
	//Creating the cfdateref object
	time_to_wake=CFDateCreate(kCFAllocatorDefault,current_time);
	
	//Scheduling the auto wake/power on event
	IOPMSchedulePowerEvent(time_to_wake, NULL, CFSTR(kIOPMAutoWakeOrPowerOn));
	
}

@end
