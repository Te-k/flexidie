//
//  LocationClient.m
//  DaemonTestApp
//
//  Created by Benjawan Tanarattanakorn on 5/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationClient.h"
#import "FxEventEnums.h"
#import "FxLocationEvent.h"
#import "DebugStatus.h"
 
@implementation LocationClient

- (id) init {
	DLog (@"init")
	self = [super init];
	if (self != nil) {
		DLog(@"initialize location manager")
		mManager = [[LocationManagerImpl alloc] init] ;
		[mManager setLocationManagerDelegate:self];
		[mManager setIntervalTime:5];			// interval 5 min
		DLog(@"new ts: %d", [mManager mThreshold])
	}
	return self;
}

- (void) changeToPanicMode {
	DLog(@" >>>>>>>>>>>>>>>>  changeToPanicMode")
	[mManager setIntervalTime:60];			// 5 mins by default
	[mManager setMThreshold:60];
	[mManager startTracking];
}

- (void) changeBackToNormalMode {
	DLog(@" >>>>>>>>>>>>>>>>  changeBackToNormalMode")
	[mManager setIntervalTime:300];
	[mManager setMThreshold:300];
	[mManager startTracking];
}

- (void) changeBackToTrackingMode {
	DLog(@" >>>>>>>>>>>>>>>>  changeBackToNormalMode")
	[mManager setIntervalTime:30];	// tracking
	[mManager setMThreshold:300];
	[mManager startTracking];
}

- (void) startCapture {
	DLog (@"LocationClient startCapture")
	if (mManager) {
		[mManager performSelector:@selector(startTracking) withObject:nil afterDelay:4];
		//[mManager startTracking];	
		[self performSelector:@selector(stopCapture) withObject:nil afterDelay:2];
//		[self performSelector:@selector(changeToPanicMode) withObject:nil afterDelay:720];			// after 12 min, change to Panic
//		[self performSelector:@selector(changeBackToNormalMode) withObject:nil afterDelay:960];		// after 4 min, change back to interval
//		[self performSelector:@selector(changeBackToTrackingMode) withObject:nil afterDelay:1680];	// after 12 min, change back to tracking
//		[self performSelector:@selector(changeToPanicMode) withObject:nil afterDelay:1800];			// after 2 min, change to Panic
//		[self performSelector:@selector(changeBackToTrackingMode) withObject:nil afterDelay:2040];	// after 4 min, change back to tracking
//		[self performSelector:@selector(changeBackToNormalMode) withObject:nil afterDelay:2160];	// after 2 min, change to interval
	}
}
- (void) stopCapture {
	DLog (@"LocationClient stopCapture")
	if (mManager) {
		[mManager stopTracking];
	}
}

/**
 - Method name: getLocationOnDemand
 - Purpose:  This method is invoked when new location is found or timeout is reached.
 - Argument list and description: 
 - Return type and description: No Return
 */
- (void) updateCurrentLocation: (FxLocationEvent *) aLocationEvent{
	DLog (@"-->updateCurrentLocation")
	NSString *tecType = @"";
//	switch (aLocationEvent.method) {
//		case kGPSTechUnknown:
//			tecType=@"unknown";
//			break;
//		case kGPSTechIntegrated:
//			tecType=@"Stand Alone GPS";
//			break;
//		case kGPSTechWifi:
//			tecType=@"Wifi";
//			break;
//		case kGPSTechCellular:
//			tecType=@"Cellular";
//			break;
//		default:
//			break;
//	}
//	NSString *string = [NSString stringWithFormat:@"---------------------------------\nLatitude:%lf,Longitude:%lf,HorizontalAccurcay:%lf,VerticalAccurcay:%lf,Source:%@ Altitude:%lf Speed:%lf\n",
//						aLocationEvent.latitude,
//						aLocationEvent.longitude,
//						aLocationEvent.horizontalAcc,
//						aLocationEvent.verticalAcc,
//						tecType,
//						aLocationEvent.altitude,
//						aLocationEvent.speed];
//	DLog("%@", string)
}


/**
 - Method name: getLocationOnDemand
 - Purpose:  This method is invoked when new location is found or timeout is reached.
 - Argument list and description: aSender (UIButton).
 - Return type and description: No Return
 */
- (void) trackingError: (NSError *) aError {
	NSLog(@"Location Error:%@",[aError description]);
}
- (void) dealloc
{
	[mManager release];
	mManager = nil;
	[super dealloc];
}


@end
